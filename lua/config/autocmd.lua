local mu = require('myutils')

local M = {}
local my_augroup = vim.api.nvim_create_augroup('11ea7949-c92d-4a4e-85d6-5208fa4b3b44', { clear = true })
M.my_augroup = my_augroup

local function save_session()
  if vim.g.mysession_was_loaded == nil then
    return
  end

  if vim.fn.filereadable(vim.g.mysession_was_loaded) == 0 then
    return
  end

  vim.cmd('mksession! ' .. vim.fn.fnameescape(vim.g.mysession_was_loaded))
end

vim.api.nvim_create_autocmd('SessionLoadPost', {
  group = my_augroup,
  callback = function()
    local sessionfpath = mu.relative_to_cwd(vim.v.this_session)
    if sessionfpath:sub(1, #mu.SESSION_FILE) ~= mu.SESSION_FILE then
      return true
    end

    -- vim.print('session loaded!')

    vim.g.mysession_was_loaded = sessionfpath
    vim.opt.swapfile = false
    vim.opt.backup = false
    vim.opt.undofile = false

    local read_undo_cached = mu.CachedFn:new(
      function(fpath)
        mu.read_undo(fpath)
        -- vim.print('readundo!' .. fpath)
      end,
      mu.cache_key_1
    )

    vim.api.nvim_create_autocmd({ 'BufEnter', 'VimEnter' }, {
      group = my_augroup,
      pattern = '*',
      callback = function(ev)
        if #ev.file == 0 then
          return
        end
        local fpath = ev.file
        if fpath:sub(1, 1) == '/' then
          fpath = mu.relative_to_cwd(ev.file)
        end
        read_undo_cached(fpath)
      end,
    })

    vim.api.nvim_create_autocmd('BufDelete', {
      group = my_augroup,
      pattern = '*',
      callback = function(ev)
        if #ev.file == 0 then
          return
        end
        local fpath = ev.file
        if fpath:sub(1, 1) == '/' then
          fpath = mu.relative_to_cwd(ev.file)
        end
        read_undo_cached:remove_key(fpath)
        -- vim.print('removed_undo:' .. fpath)
      end
    })

    vim.api.nvim_create_autocmd('BufWritePost', {
      group = my_augroup,
      pattern = '*',
      callback = function(ev)
        return mu.write_undo(mu.relative_to_cwd(ev.file))
      end,
    })

    vim.api.nvim_create_autocmd(
      'VimLeave',
      {
        group = my_augroup,
        callback = function()
          for _, n in ipairs(vim.api.nvim_list_bufs()) do
            if vim.fn.bufname(n):match('NvimTree_[0-9]+')
                or vim.fn.bufname(n):match('undotree_[0-9]+') then
              vim.api.nvim_buf_delete(n, { force = true })
            end
          end
          return true
        end
      }
    )

    vim.api.nvim_create_autocmd(
      {
        'BufEnter',
        'BufFilePost',
        'BufWritePost',
        'VimLeave'
      },
      {
        group = my_augroup,
        callback = save_session
      }
    )

    local rc_file = mu.RC_FILE .. '.lua'
    if vim.fn.filereadable(rc_file) == 1 then
      vim.cmd('luafile ' .. vim.fn.fnameescape(rc_file))
    end

    local suffix = sessionfpath:sub(#mu.SESSION_FILE + 1)
    if #suffix > 0 then
      rc_file = mu.RC_FILE .. suffix .. '.lua'
      if vim.fn.filereadable(rc_file) == 1 then
        vim.cmd('luafile ' .. vim.fn.fnameescape(rc_file))
      end
    end

    return true
  end
})

vim.api.nvim_create_autocmd({ 'BufWinEnter' }, {
  group = my_augroup,
  desc = 'return cursor to where it was last time closing the file',
  pattern = '*',
  callback = function()
    if not vim.fn.expand('%'):match('COMMIT_EDITMSG$') then
      vim.cmd('silent! normal! g`"zv')
    end
  end,
})

vim.api.nvim_create_autocmd({ 'BufRead' }, {
  group = my_augroup,
  desc = 'Detect other file types',
  pattern = '*',
  callback = function(ev)
    local bufnr = ev.buf
    if vim.bo[bufnr].filetype == '' or vim.bo[bufnr].filetype == 'conf' then
      local first_line = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1]
      if first_line and vim.startswith(first_line, "#!/usr/bin/env -S uv run") then
        vim.bo[bufnr].filetype = "python"
      end
    end
    if vim.bo[bufnr].filetype == '' and vim.fn.expand('%'):match('.jade$') then
      vim.bo[bufnr].filetype = "pug"
    end
  end
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.opt_local.textwidth = 0
    vim.opt_local.formatoptions:remove({ "t", "c" })
  end,
})

return M
