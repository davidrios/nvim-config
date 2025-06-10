local function my_on_attach(bufnr)
  local api = require "nvim-tree.api"

  local function opts(desc)
    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  -- default mappings
  api.config.mappings.default_on_attach(bufnr)

  -- custom mappings
  vim.keymap.set("n", ">", ":/[]<cr>:noh<cr>", opts("Select next folder"))
  vim.keymap.set("n", "<", ":?[]<cr>:noh<cr>", opts("Select previous folder"))
end

local IGNORE_FILES = {
  ".-/%.git$",
  ".-/node_modules$",
}

return {
  {
    "nvim-tree/nvim-tree.lua",
    config = function()
      require("nvim-tree").setup {
        on_attach = my_on_attach,
        view = {
          width = 40,
          number = true,
          relativenumber = true
        },
        filters = {
          git_ignored = false,
          custom = function(path)
            for _, i in ipairs(IGNORE_FILES) do
              if string.find(path, i) then
                return true
              end
            end
          end
        },
      }
    end
  }
}
