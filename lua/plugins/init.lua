
local overrides = require("../configs.overrides")
local dap = require("../dap")

---@type NvPluginSpec[]
local plugins = {

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

  {
    "williamboman/mason.nvim",
    opts = overrides.mason
  },
  {
    "neovim/nvim-lspconfig",
    event = { "VeryLazy", "BufRead" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require("mason-lspconfig").setup({
        automatic_installation = true,
      })
      require "nvchad.configs.lspconfig"
      require "configs.lspconfig"
    end, -- Override to setup mason-lspconfig
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = overrides.treesitter,
  },
  { -- Formatter
    "stevearc/conform.nvim",
    --  for users those who want auto-save conform + lazyloading!
    -- event = "BufWritePre"
    config = function()
      require "configs.conform"
    end,
  },

 -- NVCHAD default changings
  {
    "nvim-tree/nvim-tree.lua",
    opts = overrides.nvimtree,
  },
	{
		"nvim-telescope/telescope.nvim",
		opts = overrides.telescope,
	},
  {
    "lewis6991/gitsigns.nvim",
    opts = overrides.gitsigns,
    dependencies = {
      {
        "sindrets/diffview.nvim",
        config = true,
      },
    }
  },
	{
		"hrsh7th/nvim-cmp",
		opts = overrides.cmp,
	},

  -- DAP Configuration
  {
		"mfussenegger/nvim-dap",
		config = dap.dap_config,
  },
  {
		"rcarriga/nvim-dap-ui",
    event = "VeryLazy",
		-- config = require("dap.ui"),
    config = dap.ui,
		dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
	},
  {
    "jay-babu/mason-nvim-dap.nvim",
    -- event = "VeryLazy",
    dependencies = {
      "williamboman/mason.nvim",
      "mfussenegger/nvim-dap",
    },
    opts = {
      ensure_installed = {
        "codelldb",
      },
      automatic_installation = true,
      -- handlers = require("dap").handlers
      -- handlers = dap.handlers
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
  {
    "folke/neoconf.nvim",
  },


  {"NvChad/nvcommunity"},
  { import = "nvcommunity.motion.hop" },
      -- map("n", "<leader><leader>w", "<CMD> HopWord <CR>", { desc = "Hint all words" })
      -- map("n", "<leader><leader>t", "<CMD> HopNodes <CR>", { desc = "Hint Tree" })
      -- map("n", "<leader><leader>c", "<CMD> HopLineStart<CR>", { desc = "Hint Columns" })
      -- map("n", "<leader><leader>l", "<CMD> HopWordCurrentLine<CR>", { desc = "Hint Line" })
  { import = "nvcommunity.motion.bookmarks" },
  { import = "nvcommunity.motion.neoscroll" },
    -- <C-d> for going for ctrl-down, <C-u> for going up
  { import = "nvcommunity.motion.harpoon" },
  { import = "nvcommunity.editor.rainbowdelimiters" }, -- color brackets
  -- { import = "nvcommunity.editor.biscuits" },
  { import = "nvcommunity.editor.hlargs" }, -- higlight arguments
  { import = "nvcommunity.editor.beacon" }, -- cursor flash on jumps
  { import = "nvcommunity.editor.illuminate" }, -- highlights others words similar to the word under the cursor
  { import = "nvcommunity.editor.treesittercontext" }, -- show code context, first line of block on scroll
  { import = "nvcommunity.editor.treesj" }, -- <leader>m splitting or joining the code
  { import = "nvcommunity.file-explorer.oil-nvim" },
  -- { import = "nvcommunity.folds.fold-cycle" },
  -- { import = "nvcommunity.folds.origami" },
  { import = "nvcommunity.folds.ufo" },
  { import = "nvcommunity.diagnostics.trouble" },
  { import = "nvcommunity.diagnostics.errorlens" },
  -- { import = "nvcommunity.lsp.barbecue" },
  { import = "nvcommunity.lsp.lspsaga" },
  { import = "nvcommunity.lsp.dim" },
  -- { import = "nvcommunity.lsp.mason-lspconfig" },
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
  -- Change buffer style
  {
    'akinsho/bufferline.nvim',
    version = "*",
    lazy = false,
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function ()
      -- vim.opt.termguicolors = true
      require("bufferline").setup({
        options = {
          -- separator_style = "slope",
          indicator = {
              icon = '▎', -- this should be omitted if indicator style is not 'icon'
              style = 'underline',
          },
          -- diagnostics = "nvim_lsp",
          hover = {
            enabled = true,
            delay = 150,
            reveal = {'close'}
          },
        },

        highlights = {
          buffer_selected = {
            fg = 'orange',
            bold = true,
            italic = true,
          },

        },
      })
    end

  },
  { -- reduce escaping time with kj
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    config = function()
      require("better_escape").setup()
    end,
  },

  {
    "akinsho/toggleterm.nvim",
    version = "*",
    event = "VeryLazy",
    opts = {
      size = 15,
      open_mapping = "<c-t>",
    }
  },

  {
  	"L3MON4D3/LuaSnip",
    tag = "v2.*",
    config = function()
      require("luasnip.loaders.from_lua").lazy_load({paths="~/.config/nvim/lua/custom/configs/snippets"})
    end
  },
  {
    "smoka7/multicursors.nvim",
    event = "VeryLazy",
    dependencies = {
        'smoka7/hydra.nvim',
    },
    opts = {},
    cmd = { 'MCstart', 'MCvisual', 'MCclear', 'MCpattern', 'MCvisualPattern', 'MCunderCursor' },
    keys = {
      {
        mode = { 'v', 'n' },
        '<Leader>m',
        '<cmd>MCstart<cr>',
        desc = 'Create a selection for selected text or word under the cursor',
      },
    },
  },
  {
    "petertriho/nvim-scrollbar",
     event = "BufWinEnter",
    opts = { excluded_filetypes = { "prompt", "TelescopePrompt", "noice", "notify", "neo-tree" } },
  },
  {
    "hedyhli/outline.nvim",
    lazy = true,
    cmd = { "Outline", "OutlineOpen" },
    keys = { -- Example mapping to toggle outline
      { "<leader>o", "<cmd>Outline<CR>", desc = "Toggle outline" },
    },
    opts = {
      -- Your setup opts here
    },
  },
  {
    "olimorris/persisted.nvim",
    lazy = false,
    config = function ()
      -- require("telescope").load_extension("persisted")
      require("persisted").setup({
        autoload = true,
        on_autoload_no_session = function()
          vim.notify("No existing session to load.")
        end
      })
    end
  },

  -- Language Support
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
}

return plugins
