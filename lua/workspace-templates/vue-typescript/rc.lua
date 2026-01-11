local mu = require('myutils')
local config = require('config.autocmd')

mu.extend_global_g_args({ '!.nuxt', '!yarn.lock', '!.output', '!.cache', '!.yarn', '!test-report.junit.xml' })

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
  init_options = {
    typescript = {
      tsdk = node_modules .. '/typescript/lib'
    }
  },
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
    'javascriptreact',
    'javascript.jsx',
    'typescript',
    'typescriptreact',
    'typescript.tsx',
    'vue',
  },
})

vim.lsp.enable('efm')
local prettier = require('efmls-configs.formatters.prettier')

local languages = {
  typescript = { prettier },
  typescriptreact = { prettier },
  vue = { prettier },
  -- css = { prettier, linter_prettier },
  -- html = { prettier },
  -- json = { prettier },
  -- jsonc = { prettier },
}

local efm_config = {
  -- cmd = {'efm-langserver', '-c', '/home/node/.config/efm-langserver/config.yaml'},
  filetypes = vim.tbl_keys(languages),
  settings = {
    languages = languages,
    -- logfile = '/tmp/efm.log',
    -- loglevel = 10,
  },
}
vim.lsp.config('efm', efm_config)

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'typescript', 'typescriptreact', 'vue', 'html', 'css', 'json', 'jsonc' },
  group = config.my_augroup,
  callback = function(opts)
    vim.keymap.set("n", "<c-s>", function()
      require("conform").format()
      -- vim.lsp.buf.format({ name = 'efm' })
      vim.cmd.w()
    end, { desc = "Reformat and write buffer", buffer = opts.buf })
  end,
})

-- vim.api.nvim_create_autocmd('FileType', {
--   pattern = { 'typescript' },
--   group = config.my_augroup,
--   callback = function(opts)
--     require('otter').activate()
--   end,
-- })
