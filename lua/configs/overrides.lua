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

M.mason_lsp = {
    "html", "cssls", "tsserver", "clangd", "pyright", "texlab", "yamlls", "csharp_ls", "lua_ls", "mesonlsp"
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
