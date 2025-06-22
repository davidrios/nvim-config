local mu = require('myutils')

local M = {}

function M.init(rc_file)
  local rc_dir = rc_file:parent()
  local lsp_dir = rc_dir:joinpath('lsp')
  lsp_dir:mkdir({ parents = false, exists_ok = true })

  if not lsp_dir:joinpath('package.json'):exists() then
    local res = mu.arun_job({ command = 'npm', args = { 'init', '-y' }, cwd = lsp_dir:normalize() })
    if res.code ~= 0 then
      mu.anotify(res:stderr_result())
      mu.anotify('error creating node package', vim.log.levels.ERROR)
      return
    end
  end

  return lsp_dir
end

function M.install_node_packages(lsp_dir, packages)
  mu.anotify('installing node packages...', vim.log.levels.TRACE)

  local args = { 'install', '-D' }
  for _, val in vim.spairs(packages) do
    table.insert(args, val)
  end

  local res = mu.arun_job({
    command = 'npm',
    args = args,
    cwd = lsp_dir:normalize(),
  })

  if res.code ~= 0 then
    mu.anotify(res:stderr_result())
    mu.anotify('error adding node packages', vim.log.levels.ERROR)
    return
  end

  mu.anotify('node packages installed', vim.log.levels.TRACE)
  return true
end

return M
