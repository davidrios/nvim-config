vim.opt.relativenumber = true
vim.opt.nu = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes:2"
vim.opt.colorcolumn = "80,120"
--vim.opt.paste = true

vim.opt.tabline = '%!v:lua.require(\'myutils\').my_tab_line()'

vim.cmd.colorscheme("catppuccin-mocha")

vim.lsp.config('*', {
  capabilities = {
    textDocument = {
      semanticTokens = {
        multilineTokenSupport = true,
      }
    },
    offsetEncoding = { 'utf-16' },
    general = {
      positionEncodings = { 'utf-16' },
    },
  },
  root_markers = { '.git' },
})

vim.lsp.config('basedpyright', {
  settings = {
    basedpyright = {
      analysis = {
        diagnosticMode = "openFilesOnly",
      },
      typeCheckingMode = "basic"
    }
  }
})
