local node_base = require('workspace-templates.node-base')
local utils = require('workspace-templates.utils')

local M = {}

function M.setup(rc_file)
  local lsp_dir = node_base.init(rc_file)
  if lsp_dir == nil then
    return
  end

  if not node_base.install_node_packages(
        lsp_dir, { 'typescript-language-server', 'typescript', '@vue/language-server', '@vue/typescript-plugin', 'vscode-langservers-extracted', 'eslint-formatter-visualstudio' }
      ) then
    return
  end

  return utils.copy_rc_file(rc_file, 'vue-typescript')
end

return M
