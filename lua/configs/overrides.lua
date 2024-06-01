local M = {}


M.treesitter = {
  -- https://github.com/nvim-treesitter/nvim-treesitter#supported-languages
  ensure_installed = {
    "astro",
    "vim",
    "vimdoc",
    "v",

    "nim",
    "lua",
    "html",
    "css",
    "javascript",
    "typescript",
    "tsx",
    "c",
    "markdown",
    "markdown_inline",
    "python",
    "latex",
    "bibtex",
    "c_sharp",
    "meson"
  },
  indent = {
    enable = true,
    -- disable = {
    --   "python"
    -- },
  },
  highlight = {
    disable = {
      "latex"
    }
  }

}

M.mason = {
  ensure_installed = {
    -- lua stuff
    "stylua",

    -- web dev stuff
    "deno",
    "prettier",

    -- c/cpp stuff
    "clang-format",

    -- python
    "black",
    "debugpy",

    -- c#
    "csharpier",

  },
}

-- https://github.com/williamboman/mason-lspconfig.nvim#available-lsp-servers
M.mason_lsp = {
    "html", "cssls", "tsserver", "clangd", "pyright", "texlab", "yamlls", "csharp_ls", "lua_ls", "mesonlsp", "jsonls"
}

-- git support in nvimtree
M.nvimtree = {
  git = {
    enable = true,
  },

  renderer = {
    highlight_git = true,
    icons = {
      show = {
        git = true,
      },
    },
  },
}

M.telescope = {
	defaults = {
		vimgrep_arguments = {
			"rg",
			"-L",
			"--color=never",
			"--no-heading",
			"--with-filename",
			"--line-number",
			"--column",
			"--smart-case",
			"--hidden",
		},
		mappings = {
			i = {
				["<esc>"] = function(...)
					require("telescope.actions").close(...)
				end,
			},
		},
	},
  extensions = {
    persisted = {
      layout_config = { width = 0.55, height = 0.55 }
    }
  }
}

M.gitsigns = {
	signs = {
		add = { hl = "GitSignsAdd", text = "+", numhl = "GitSignsAddNr" },
	},
}

M.cmp = {
	formatting = {
		format = function(entry, vim_item)
			local icons = require("nvchad.icons.lspkind")
			vim_item.kind = string.format("%s %s", icons[vim_item.kind], vim_item.kind)
			vim_item.menu = ({
				luasnip = "[Luasnip]",
				nvim_lsp = "[Nvim LSP]",
				buffer = "[Buffer]",
				nvim_lua = "[Nvim Lua]",
				path = "[Path]",
			})[entry.source.name]
			return vim_item
		end,
	},
}

return M
