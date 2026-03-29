return {
  {
    "mg979/vim-visual-multi",
    event = "VeryLazy",
  },
  {
    "folke/snacks.nvim",
    opts = {
      image = { enabled = true },
      math = {
        latex = { font_size = "normalsize" },
      },
    },
  },
  {
    "nvim-neotest/neotest",
    dependencies = { "nvim-neotest/nvim-nio" },
  },
  {
    "folke/zen-mode.nvim",
  },
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({})
      -- surr*ound_words             ysiw)           (surround_words)
      -- *make strings               ys$"            "make strings"
      -- [delete ar*ound me!]        ds]             delete around me!
      -- remove <b>HTML t*ags</b>    dst             remove HTML tags
      -- 'change quot*es'            cs'"            "change quotes"
      -- <b>or tag* types</b>        csth1<CR>       <h1>or tag types</h1>
      -- delete(functi*on calls)     dsf             function calls
    end,
  },
  {
    "m4xshen/hardtime.nvim",
    lazy = false,
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {},
  },
  {
    "https://codeberg.org/esensar/nvim-dev-container",
    dependencies = "nvim-treesitter/nvim-treesitter",
    event = "VeryLazy",
    config = function()
      require("devcontainer").setup({})
    end,
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    keys = {
      -- swap behavior
      { "<leader>e", "<leader>fE", desc = "Explorer NeoTree (Root Dir)", remap = true },
      { "<leader>E", "<leader>fe", desc = "Explorer NeoTree (cwd)", remap = true },
    },
  },
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
    config = true,
    keys = {
      { "<leader>gc", "<cmd>DiffviewOpen<cr>", desc = "DiffView Open" },
      { "<leader>gC", "<cmd>DiffviewClose<cr>", desc = "DiffView Close" },
    },
  },
  -- {
  --   "yetone/avante.nvim",
  --   opts = function(_, opts)
  --     -- Change only the provider
  --     opts.provider = "ollama"
  --
  --     opts.max_tokens = 256
  --     opts.debounce = 400
  --     opts.context_lines = 80
  --
  --     -- Add / override only ollama config
  --     opts.providers = opts.providers or {}
  --     opts.providers.ollama = {
  --       model = "deepseek-coder:1.3b",
  --       is_env_set = require("avante.providers.ollama").check_endpoint_alive,
  --     }
  --   end,
  -- },
  --
}
