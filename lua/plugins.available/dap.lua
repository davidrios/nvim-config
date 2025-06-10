return {
  {'mfussenegger/nvim-dap'},
  {'mfussenegger/nvim-dap-python'},
  {
    'theHamsta/nvim-dap-virtual-text',
    config = function()
      require('nvim-dap-virtual-text').setup({
        virt_lines = true
      })
    end
  }
}
