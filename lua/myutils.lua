local A = require('plenary.async')
local Job = require('plenary.job')
local Path = require('plenary.path')
local sha1 = require('sha1')

local M = {}

local function prequire(...)
  local status, lib = pcall(require, ...)
  if (status) then return lib end
  vim.print('Failed to require ' .. ...)
  return nil
end
M.prequire = prequire

local telescope = prequire("telescope.builtin")

local SESSION_PREFIX = '.neovim'
if vim.fn.filereadable('.idea/neovim/session') == 1 then
  SESSION_PREFIX = '.idea/neovim'
elseif vim.fn.filereadable('.vscode/neovim/session') == 1 then
  SESSION_PREFIX = '.vscode/neovim'
end
M.SESSION_PREFIX = SESSION_PREFIX

local SESSION_FILE = SESSION_PREFIX .. '/session'
M.SESSION_FILE = SESSION_FILE

local RC_FILE = SESSION_PREFIX .. '/rc'
M.RC_FILE = RC_FILE

local UNDO_DIR = SESSION_PREFIX .. '/undo'
M.UNDO_DIR = UNDO_DIR

local function get_last_x(my_list, x)
  local len = #my_list
  local start_index = math.max(1, len - x + 1)
  local last_x = {}

  for i = start_index, len do
    table.insert(last_x, my_list[i])
  end

  return last_x
end
M.get_last_x = get_last_x

local function str_join(chr, arr, fn)
  if #arr == 0 then
    return ''
  end
  local rest = ''
  for i, p in vim.spairs(arr) do
    rest = rest .. ((i > 1) and chr or '') .. (fn ~= nil and fn(p, i) or p)
  end
  return rest
end
M.str_join = str_join

local CACHE_NIL_KEY = {}
local _global_cache = {}
local _cache_id = 0

local CachedFn = {}
CachedFn.__index = CachedFn

function CachedFn:new(fn, cache_key_fn, global_key)
  local instance = {}
  setmetatable(instance, self)
  instance._cache_id = _cache_id
  _cache_id = _cache_id + 1

  if global_key ~= nil and _global_cache[global_key] ~= nil then
    instance._cache = _global_cache[global_key]
  else
    instance._cache = {}
  end

  instance._fn = fn
  instance._cache_key_fn = cache_key_fn
  return instance
end

function CachedFn:_get_key(...)
  local key = CACHE_NIL_KEY
  if self._cache_key_fn ~= nil then
    key = self._cache_key_fn(...)
  end

  if key == nil then
    key = CACHE_NIL_KEY
  end

  return key
end

function CachedFn:__call(...)
  --vim.print('CachedFnCall', ...)

  local key = self:_get_key(...)
  if self._cache[key] ~= nil then
    local value = self._cache[key][1]
    -- vim.print(str_join(':', {'retrieved', self._cache_id, key, value}, tostring))
    return value
  end

  local value = self._fn(...)
  self._cache[key] = { value }
  -- vim.print(str_join(':', {'computed', self._cache_id, key, value}, tostring))
  return value
end

function CachedFn:remove_key(...)
  local key = self:_get_key(...)
  -- vim.print(str_join(':', {'removed', self._cache_id, key, '!'}, tostring))
  self._cache[key] = nil
end

M.CachedFn = CachedFn

local function cache_key_1(arg1) return arg1 end
M.cache_key_1 = cache_key_1

local IGNORE_BUF_NAME = { '^NvimTree_[0-9]+', '^undotree_', '^diffpanel_' }

local function match_any(patterns, cmp)
  for i = 1, #patterns do
    if cmp:match(patterns[i]) then
      return true
    end
  end
  return false
end
M.match_any = match_any

local function my_tab_label(n)
  local buflist = vim.fn.tabpagebuflist(n)
  local i = 1
  while i <= #buflist and match_any(IGNORE_BUF_NAME, vim.fn.bufname(buflist[i])) do
    i = i + 1
  end

  if i > #buflist then
    i = #buflist
  end

  local bufnr = buflist[i]
  local bufname = vim.fn.bufname(bufnr)
  if #bufname == 0 then
    bufname = '[No Name]'
  end

  local parts = get_last_x(vim.split(bufname, '/'), 3)
  local fname = table.remove(parts)
  if #fname > 20 then
    fname = string.sub(fname, 0, 19) .. '…'
  end

  local rest = str_join('/', parts, function(part) return part:sub(1, 3) end)
  if #rest > 0 then
    rest = '(' .. rest .. ')'
  end
  return n .. ':' .. fname .. (vim.bo[bufnr].modified and '*' or '') .. rest
end
M.my_tab_label = my_tab_label

local function relative_to_cwd(fpath)
  return Path:new(fpath):make_relative(vim.fn.getcwd())
end
M.relative_to_cwd = relative_to_cwd

local function my_tab_line()
  local s = ''
  local tabnr_last = vim.fn.tabpagenr('$')
  local tabnr_current = vim.fn.tabpagenr()

  for i = 1, tabnr_last do
    if i == tabnr_current then
      s = s .. '%#TabLineSel#'
    else
      s = s .. '%#TabLine#'
    end
    s = s .. '%' .. i .. 'T'
    s = s .. ' %{v:lua.require(\'myutils\').my_tab_label(' .. i .. ')}'
  end

  s = s .. '%#TabLineFill#%T'

  if tabnr_last > 1 then
    s = s .. '%=%#TabLine#%999Xclose'
  end

  return s
end
M.my_tab_line = my_tab_line

local undo_path_levels = 3
local function _gen_undo_fpath(fpath)
  local fname = sha1(fpath)
  local parts = { UNDO_DIR }
  for i = 1, undo_path_levels do
    table.insert(parts, string.sub(fname, i, i))
  end
  table.insert(parts, fname)
  return parts
end
M._gen_undo_fpath = _gen_undo_fpath

vim.api.nvim_create_user_command('MyUtilsUndoPath', function()
  vim.print(str_join('/', _gen_undo_fpath(relative_to_cwd(vim.fn.expand('%')))))
end, {})

local _read_undo_fpath = CachedFn:new(
  function(fpath)
    local genfpath = _gen_undo_fpath(fpath)
    return str_join('/', genfpath)
  end,
  cache_key_1
)
local function read_undo(fpath)
  local undo_file_path = _read_undo_fpath(fpath)
  if vim.fn.filereadable(undo_file_path) == 1 then
    vim.cmd('silent rundo ' .. vim.fn.fnameescape(undo_file_path))
    -- vim.print('readundo! ' .. undo_file_path)
  end
end
M.read_undo = read_undo
vim.api.nvim_create_user_command(
  'MyUtilsReadUndo',
  function() read_undo(relative_to_cwd(vim.fn.expand('%'))) end,
  {}
)

local _write_undo_fpath = CachedFn:new(
  function(fpath)
    local undo_file_path = _gen_undo_fpath(fpath)
    local fname = undo_file_path[#undo_file_path]
    local undo_file_dir = ''
    for i = 1, #undo_file_path - 1 do
      undo_file_dir = undo_file_dir .. (i > 1 and '/' or '') .. undo_file_path[i]
    end

    return { undo_file_dir, fname }
  end,
  cache_key_1
)
M._write_undo_fpath = _write_undo_fpath
local function write_undo(fpath)
  local undo_file_dir, fname = unpack(_write_undo_fpath(fpath))
  if #undo_file_dir > 0 then
    vim.fn.mkdir(undo_file_dir, 'p')
  end
  vim.cmd('silent wundo ' .. vim.fn.fnameescape(undo_file_dir .. '/' .. fname))
end
M.write_undo = write_undo

local function genAttachPython(name, port, remoteRoot)
  return {
    type = 'python',
    request = 'attach',
    name = 'attach ' .. name,
    pathMappings = {
      { localRoot = vim.fn.getcwd(), remoteRoot = remoteRoot or vim.fn.getcwd() }
    },
    connect = function()
      local host = '127.0.0.1'
      return { host = host, port = port }
    end,
  }
end
M.genAttachPython = genAttachPython

function M.feedkeys(keys, mode)
  if mode == nil then
    mode = 'n'
  end
  local processed_keys = vim.api.nvim_replace_termcodes(keys, true, true, true)
  vim.api.nvim_feedkeys(processed_keys, mode, false)
end

function M.setup_workspace_rc(name)
  local mod = prequire('workspace-templates/' .. name)
  if mod == nil then
    vim.notify('error: workspace template "' .. name .. '" not found', vim.log.levels.ERROR)
    return
  end

  if vim.fn.filereadable(SESSION_FILE) ~= 1 then
    vim.notify('error: session file does not exist, create it first', vim.log.levels.ERROR)
    return
  end

  local rc_file_name = 'rc-' .. name .. '.lua'
  local ws_rc_file = Path:new(SESSION_PREFIX):joinpath(rc_file_name)

  if ws_rc_file:exists() then
    vim.notify(
      'error: workspace template rc file "' .. rc_file_name .. '" already exists, not overwritting',
      vim.log.levels.ERROR)
    return
  end

  A.run(function()
    if mod.setup(ws_rc_file) then
      M.anotify(
        'workspace rc file created, source it by adding "require(\'myutils\').source_rc(\'' ..
        name .. '\')" to your rc.lua and restart')
      vim.schedule(function()
        M.source_rc(name)
      end)
    end
  end)
end

function M.source_rc(name)
  vim.cmd('luafile ' .. vim.fn.fnameescape(SESSION_PREFIX .. '/' .. 'rc-' .. name .. '.lua'))
end

vim.api.nvim_create_user_command('MyUtilsSetupRC', function(args)
  M.setup_workspace_rc(args.fargs[1])
end, {
  nargs = 1,
  complete = function()
    local scan = require('plenary.scandir')
    local ws_templates_path = vim.fn.stdpath('config') .. '/lua/workspace-templates'
    local ws_dirs = scan.scan_dir(ws_templates_path, { hidden = false, depth = 1, only_dirs = true })
    local only_names = {}
    for i = 1, #ws_dirs do
      local parts = vim.split(ws_dirs[i], '/')
      table.insert(only_names, parts[#parts])
    end
    return only_names
  end,
})

local function _arun_job(opts, callback)
  if opts.command == nil then
    Job:new(opts):after(callback):start()
  else
    opts.on_exit = function(res)
      callback(res)
    end
    Job:new(opts):start()
  end
end
M.arun_job = A.wrap(_arun_job, 2)

function M.anotify(arg1, arg2, arg3)
  vim.schedule(function()
    vim.notify(arg1, arg2, arg3)
  end)
end

local global_g_args = { '!node_modules', '!.idea', '!.vscode', '!.neovim', '!.venv' }
function M.extend_global_g_args(g_args)
  for i = 1, #g_args do
    table.insert(global_g_args, g_args[i])
  end
end

if telescope then
  function M.live_grep(us, g_args)
    local vimgrep_arguments = {
      "rg", "--color=never", "--no-heading", "--with-filename", "--line-number",
      "--column", "--smart-case", }

    if us ~= nil and us > 0 then
      local au = '-'
      for _ = 1, us do
        au = au .. 'u'
      end
      table.insert(vimgrep_arguments, au)
    end

    if g_args ~= nil and #g_args > 0 then
      for i = 1, #g_args do
        table.insert(vimgrep_arguments, "-g")
        table.insert(vimgrep_arguments, g_args[i])
      end
    end

    telescope.live_grep({
      vimgrep_arguments = vimgrep_arguments
    })
  end

  function M.live_grep_global_g_args(us, g_args)
    if g_args == nil then
      g_args = {}
    end
    for i = 1, #global_g_args do
      table.insert(g_args, global_g_args[i])
    end
    return M.live_grep(us, g_args)
  end
end

return M
