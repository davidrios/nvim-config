local config = require('config.autocmd')
vim.lsp.enable('zls')

local zlint = require('efmls-configs.linters.zlint')

local languages = {
  zig = { zlint },
}

local efm_config = {
  filetypes = vim.tbl_keys(languages),
  settings = {
    languages = languages,
  },
}
vim.lsp.config('efm', efm_config)
vim.lsp.enable('efm')

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'zig',
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
      vim.lsp.buf.format()
      vim.wait(100, function() return false end)
      vim.cmd.w()
    end, { desc = "Reformat and write buffer", buffer = opts.buf })
  end,
})
