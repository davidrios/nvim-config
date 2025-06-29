local Path = require('plenary.path')
local mu = require('myutils')

local M = {}

function M.setup(rcFile)
  local node_base = mu.prequire('workspace-templates/node-base')
  if node_base == nil then
    mu.anotify('error: workspace template "node-lsp" not found', vim.log.levels.ERROR)
    return
  end

  local lsp_dir = node_base.init(rcFile)
  if lsp_dir == nil then
    return
  end

  if not node_base.install_node_packages(
        lsp_dir, { 'typescript-language-server', 'typescript', '@vue/language-server', '@vue/typescript-plugin', 'vscode-langservers-extracted' }
      ) then
    return
  end

  local rc_template = Path:new(vim.fn.stdpath('config') .. '/lua/workspace-templates/vue-typescript/rc.lua')
  rcFile:write(rc_template:read(), "w")

  return true
end

return M
