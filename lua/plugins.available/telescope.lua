return {
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          get_selection_window = function(picker, entry)
            local w = 0
            local b = vim.fn.bufnr(entry.filename) or vim.fn.bufadd(entry.filename)
            vim.bo[b].buflisted = true
            return vim.fn.win_findbuf(b)[1] or w
          end
        },
        extensions = {
          fzf = {
            fuzzy = true,                   -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true,    -- override the file sorter
            case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
            -- the default case_mode is "smart_case"
          }
        }
      })
      -- To get fzf loaded and working with telescope, you need to call
      -- load_extension, somewhere after setup function:
      telescope.load_extension("fzf")
    end
  }
}
