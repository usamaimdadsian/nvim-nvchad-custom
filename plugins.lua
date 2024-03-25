local overrides = require("custom.configs.overrides")
local dap = require("custom.dap.init")

---@type NvPluginSpec[]
local plugins = {

  -- Override plugin definition options

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end, -- Override to setup mason-lspconfig
  },

  -- override plugin configs
  {
    "williamboman/mason.nvim",
    opts = overrides.mason
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = overrides.treesitter,
  },

  {
    "nvim-tree/nvim-tree.lua",
    opts = overrides.nvimtree,
  },

  -- Install a plugin
  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    config = function()
      require("better_escape").setup()
    end,
  },

  {
    "stevearc/conform.nvim",
    --  for users those who want auto-save conform + lazyloading!
    -- event = "BufWritePre"
    config = function()
      require "custom.configs.conform"
    end,
  },

  -- To make a plugin not be loaded
  -- {
  --   "NvChad/nvim-colorizer.lua",
  --   enabled = false
  -- },

  -- All NvChad plugins are lazy-loaded by default
  -- For a plugin to be loaded, you will need to set either `ft`, `cmd`, `keys`, `event`, or set `lazy = false`
  -- If you want a plugin to load on startup, add `lazy = false` to a plugin spec, for example
  -- {
  --   "mg979/vim-visual-multi",
  --   lazy = false,
  -- }
  "NvChad/nvcommunity",
  { import = "nvcommunity.git.diffview" },
  { import = "nvcommunity.git.lazygit" },
  { import = "nvcommunity.motion.hop" },
  { import = "nvcommunity.motion.bookmarks" },
  { import = "nvcommunity.motion.neoscroll" },
  { import = "nvcommunity.motion.harpoon" },
  { import = "nvcommunity.editor.rainbowdelimiters" },
  -- { import = "nvcommunity.editor.biscuits" },
  { import = "nvcommunity.editor.hlargs" },
  { import = "nvcommunity.editor.illuminate" },
  { import = "nvcommunity.editor.treesittercontext" },
  { import = "nvcommunity.editor.treesj" },
  -- { import = "nvcommunity.folds.fold-cycle" },
  { import = "nvcommunity.folds.origami" },
  { import = "nvcommunity.diagnostics.trouble" },
  -- { import = "nvcommunity.lsp.barbecue" },
  { import = "nvcommunity.lsp.lspsaga" },
  { import = "nvcommunity.lsp.dim" },
  { import = "nvcommunity.lsp.mason-lspconfig" },
  -- { import = "nvcommunity.lsp.prettyhover" },

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
    end
  },
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    event = "VeryLazy",
    opts = {
      size = 10,
      open_mapping = "<c-t>",
    }
  },

  -- DAP Configuration
  {
		"mfussenegger/nvim-dap",
		config = dap.dap_config
  },
  {
		"rcarriga/nvim-dap-ui",
    event = "VeryLazy",
		config = require("custom.dap.ui"),
		dependencies = { "mfussenegger/nvim-dap" },
	},

  {
    "jay-babu/mason-nvim-dap.nvim",
    event = "VeryLazy",
    dependencies = {
      "williamboman/mason.nvim",
      "mfussenegger/nvim-dap",
    },
    opts = {
      ensure_installed = {
        "codelldb",
      },
      -- handlers = require("custom.dap").handlers
      handlers = dap.handlers
    },
  },
  {
		"theHamsta/nvim-dap-virtual-text",
		config = function()
			require("nvim-dap-virtual-text").setup()
		end,
		dependencies = { "mfussenegger/nvim-dap" },
	},
  {
    "lervag/vimtex",
    lazy = false, -- lazy-loading will disable inverse search
    config = function()
      -- vim.api.nvim_create_autocmd({ "FileType" }, {
      --   group = vim.api.nvim_create_augroup("lazyvim_vimtex_conceal", { clear = true }),
      --   pattern = { "bib", "tex" },
      --   callback = function()
      --     vim.wo.conceallevel = 2
      --   end,
      -- })
      
      vim.g.vimtex_mappings_disable = { ["n"] = { "K" } } -- disable `K` as it conflicts with LSP hover
      vim.g.vimtex_quickfix_method = vim.fn.executable("pplatex") == 1 and "pplatex" or "latexlog"
      vim.g.tex_flavor='latex'
      vim.g.vimtex_view_method='zathura'
      vim.g.vimtex_quickfix_mode=0
      vim.g.conceallevel=1
      vim.g.tex_conceal='abdmg'
      vim.g.vimtex_compiler_method='latexmk'
      -- vim.g.vimtex_compiler_method='tectonic'
    end,
  },
  {
  	"L3MON4D3/LuaSnip",
    tag = "v2.*",
    config = function()
      require("luasnip.loaders.from_lua").lazy_load({paths="~/.config/nvim/lua/custom/configs/snippets"})
    end
  },
  {
    "mfussenegger/nvim-dap-python",
    -- stylua: ignore
    keys = {
      { "<leader>dPt", function() require('dap-python').test_method() end, desc = "Debug Method", ft = "python" },
      { "<leader>dPc", function() require('dap-python').test_class() end, desc = "Debug Class", ft = "python" },
    },
    config = function()
      local path = require("mason-registry").get_package("debugpy"):get_install_path()
      require("dap-python").setup(path .. "/venv/bin/python")
    end,
  },
  -- {
  --   "rcarriga/nvim-notify",
  --   keys = {
  --     {
  --       "<leader>un",
  --       function()
  --         require("notify").dismiss({ silent = true, pending = true })
  --       end,
  --       desc = "Dismiss all Notifications",
  --     },
  --   },
  --   opts = {
  --     timeout = 3000,
  --     max_height = function()
  --       return math.floor(vim.o.lines * 0.75)
  --     end,
  --     max_width = function()
  --       return math.floor(vim.o.columns * 0.75)
  --     end,
  --     on_open = function(win)
  --       vim.api.nvim_win_set_config(win, { zindex = 100 })
  --     end,
  --   },
  --   init = function()
  --     -- when noice is not enabled, install notify on VeryLazy
  --     if not Util.has("noice.nvim") then
  --       Util.on_very_lazy(function()
  --         vim.notify = require("notify")
  --       end)
  --     end
  --   end,
  -- },
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = { options = vim.opt.sessionoptions:get() },
    -- stylua: ignore
    keys = {
      { "<leader>qs", function() require("persistence").load() end, desc = "Restore Session" },
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
      { "<leader>qd", function() require("persistence").stop() end, desc = "Don't Save Current Session" },
    },
  },
  -- require("luasnip.loaders.from_snipmate").lazy_load({paths="./snippets"})
}

return plugins
