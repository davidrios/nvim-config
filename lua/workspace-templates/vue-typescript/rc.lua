local mu = require('myutils')

local node_modules = vim.fn.getcwd() .. '/' .. mu.SESSION_PREFIX .. '/lsp/node_modules'

vim.lsp.enable('cssls')
vim.lsp.enable('jsonls')
vim.lsp.enable('html')
vim.lsp.enable('eslint')

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
