return { {
  'jmbuhr/otter.nvim',
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
  },
  config = function()
    local otter = require('otter')
    otter.setup({
      extensions = {
        glsl = "glsl",
      },
    })
  end
} }
