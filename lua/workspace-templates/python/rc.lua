local mu = require('myutils')
local config = require('config.autocmd')

require("luasnip.loaders.from_vscode").lazy_load()

mu.extend_global_g_args({ '!.pytest_cache', '!coverage.html' })

vim.lsp.enable('pylsp')
vim.lsp.enable('ruff')
-- vim.lsp.enable('ty')
vim.lsp.config('ty', {
  cmd = { 'uvx', 'ty', 'server' }
})
vim.lsp.enable('basedpyright')
vim.lsp.config('basedpyright', {
  settings = {
    basedpyright = {
      analysis = {
        diagnosticMode = "workspace",
      },
      typeCheckingMode = "off"
    }
  }
})
-- vim.lsp.enable('pyrefly')

local remoteRoot = '/backend'
local python_dap = {
  mu.genAttachPython('app1', 5678, remoteRoot),
  mu.genAttachPython('app2', 5679, remoteRoot),
  mu.genAttachPython('app3', 5680, remoteRoot),
}
require('dap-python').setup('python3')
require('dap').configurations.python = python_dap

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'python',
  group = config.my_augroup,
  callback = function(opts)
    vim.keymap.set("n", "<c-s>", function()
      vim.lsp.buf.code_action({
        context = { only = { "source.fixAll" } },
        apply = true,
      })
      vim.wait(50, function() return false end)
      vim.lsp.buf.code_action({
        context = { only = { "source.organizeImports" } },
        apply = true,
      })
      vim.wait(50, function() return false end)
      vim.lsp.buf.format({ name = 'ruff' })
      vim.cmd.w()
    end, { desc = "Reformat and write buffer", buffer = opts.buf })
  end,
})
