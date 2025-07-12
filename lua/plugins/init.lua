return {
  {
    "nvim-neotest/neotest",
    dependencies = { "nvim-neotest/nvim-nio" },
  },
  {
    "Weissle/persistent-breakpoints.nvim",
    event = "BufReadPost", -- load breakpoints when reading files
    dependencies = { "mfussenegger/nvim-dap" }, -- make sure DAP is installed
    config = function()
      require("persistent-breakpoints").setup({
        load_breakpoints_event = { "BufReadPost" },
      })

      local opts = { noremap = true, silent = true }
      local keymap = vim.api.nvim_set_keymap

      keymap("n", "<leader>db", "<cmd>lua require('persistent-breakpoints.api').toggle_breakpoint()<CR>", opts)
      keymap("n", "<leader>dB", "<cmd>lua require('persistent-breakpoints.api').set_conditional_breakpoint()<CR>", opts)
      -- keymap("n", "<leader>dl", "<cmd>lua require('persistent-breakpoints.api').set_log_point()<CR>", opts)
      -- keymap("n", "<leader>dC", "<cmd>lua require('persistent-breakpoints.api').clear_all_breakpoints()<CR>", opts)
    end,
  },
  {
    "mfussenegger/nvim-dap",
    keys = {
      {
        "<leader>do",
        function()
          require("dap").step_over()
        end,
        desc = "Step Over",
      },
      {
        "<leader>dO",
        function()
          require("dap").step_out()
        end,
        desc = "Step Out",
      },
    },
  },
  {
    "folke/zen-mode.nvim",
  },
  -- {
  --   "m4xshen/hardtime.nvim",
  --   lazy = false,
  --   dependencies = { "MunifTanjim/nui.nvim" },
  --   opts = {},
  -- },
}
