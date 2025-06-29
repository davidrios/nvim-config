local mu = require('myutils')

local node_modules = vim.fn.getcwd() .. '/' .. mu.SESSION_PREFIX .. '/lsp/node_modules'

vim.lsp.enable('cssls')
vim.lsp.config('cssls', {
  cmd = { node_modules .. '/.bin/vscode-css-language-server', '--stdio' },
})

vim.lsp.enable('jsonls')
vim.lsp.config('jsonls', {
  cmd = { node_modules .. '/.bin/vscode-json-language-server', '--stdio' },
})

vim.lsp.enable('html')
vim.lsp.config('html', {
  cmd = { node_modules .. '/.bin/vscode-html-language-server', '--stdio' },
})

vim.lsp.enable('eslint')
vim.lsp.config('eslint', {
  cmd = { node_modules .. '/.bin/vscode-eslint-language-server', '--stdio' },
})

vim.lsp.enable('vue_ls')
vim.lsp.config('vue_ls', {
  cmd = { node_modules .. '/.bin/vue-language-server', '--stdio' },
})

vim.lsp.enable('ts_ls')
vim.lsp.config('ts_ls', {
  cmd = { node_modules .. '/.bin/typescript-language-server', '--stdio' },
  init_options = {
    plugins = {
      {
        name = '@vue/typescript-plugin',
        location = node_modules .. '/@vue/typescript-plugin',
        languages = { 'vue' },
      },
    },
  },
  filetypes = {
    'javascript',
    'typescript',
    'vue',
  },
})


vim.lsp.enable('efm')
local prettier = require('efmls-configs.formatters.prettier')
local languages = {
  typescript = { prettier },
  vue = { prettier },
}
vim.lsp.config('efm', {
  filetypes = vim.tbl_keys(languages),
  settings = {
    languages = languages,
  },
})
