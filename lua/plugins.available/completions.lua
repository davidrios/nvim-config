return {
  {
    "hrsh7th/nvim-cmp",
    event = { "InsertEnter", },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        completion = {
          autocomplete = false
        },
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
            -- vim.snippet.expand(args.body)
          end
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<tab>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" }, -- For luasnip users.
        }, {
          { name = "buffer" },
        })
      })

      -- cmp.setup.cmdline({ "/", "?" }, {
      --   mapping = cmp.mapping.preset.cmdline(),
      --   sources = {
      --     { name = "buffer" }
      --   }
      -- })

      -- cmp.setup.cmdline(":", {
      --   mapping = cmp.mapping.preset.cmdline(),
      --   -- sources = cmp.config.sources({
      --   --   { name = "path" }
      --   -- }, {
      --   --   { name = "cmdline" }
      --   -- }),
      --   sources = {
      --     { name = "cmdline" }
      --   },
      --   matching = { disallow_symbol_nonprefix_matching = false }
      -- })

      -- local capabilities = require("cmp_nvim_lsp").default_capabilities()
    end
  },         -- Required
  {"hrsh7th/cmp-nvim-lsp"},     -- Required
  {"hrsh7th/cmp-buffer"},       -- Optional
  {"hrsh7th/cmp-path"},         -- Optional
  {"saadparwaiz1/cmp_luasnip"}, -- Optional
  {"hrsh7th/cmp-nvim-lua"},
  {
    "L3MON4D3/LuaSnip",
    -- follow latest release.
    version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
    -- install jsregexp (optional!).
    build = "make install_jsregexp"
  },
}
