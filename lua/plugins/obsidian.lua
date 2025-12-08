return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "latex" } },
  },
  {
    "epwalsh/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    -- lazy = true,
    ft = "markdown",
    -- event = {
    --   "BufReadPre " .. vim.fn.expand("~") .. "/linux/obsidian/obsidian-docs/*.md",
    --   "BufNewFile " .. vim.fn.expand("~") .. "/linux/obsidian/obsidian-docs/*.md",
    -- },

    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      ui = { enable = false },
      picker = { name = "snacks.picker" },
      workspaces = {
        {
          name = "personal",
          -- path = vim.fn.expand("~") .. "/linux/obsidian/obsidian-docs/",
          path = "~/linux/obsidian/obsidian-docs",
        },
      },
      before_save = function(note)
        local client = require("obsidian").get_client()
        local rel_path = note.path:sub(#client.dir + 2)
        local folders = {}
        for folder in rel_path:gmatch("([^/]+)/") do
          table.insert(folders, folder)
        end
        note.frontmatter.tags = folders
        note.frontmatter.aliases = note.frontmatter.aliases or {}
      end,
    },
  },
}
