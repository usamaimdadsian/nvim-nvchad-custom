local function obsidian_workspaces()
  local ok, local_config = pcall(require, "config.local")
  if ok and type(local_config.obsidian_workspaces) == "table" then
    return local_config.obsidian_workspaces
  end

  local vault = vim.env.OBSIDIAN_VAULT
  if vault and vault ~= "" then
    return {
      {
        name = vim.env.OBSIDIAN_VAULT_NAME or "personal",
        path = vim.fn.expand(vault),
      },
    }
  end

  return {}
end

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
      workspaces = obsidian_workspaces(),
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
