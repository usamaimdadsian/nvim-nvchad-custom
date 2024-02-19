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
    "c_sharp"
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
  -- https://github.com/williamboman/mason-lspconfig.nvim#available-lsp-servers
  ensure_installed = {
    -- lua stuff
    "lua-language-server",
    "stylua",

    -- web dev stuff
    "css-lsp",
    "html-lsp",
    "typescript-language-server",
    "deno",
    "prettier",

    -- c/cpp stuff
    "clangd",
    "clang-format",

    -- python 
    "pyright",
    "black",
    "debugpy",

    -- latex
    "texlab",

    -- c#
    "csharpier",
  },
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

return M
