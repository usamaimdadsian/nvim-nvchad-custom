-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.lazyvim_python_lsp = "basedpyright"
vim.g.equalalways = false
vim.g.root_spec = { "cwd", "lsp", { ".git", "lua" } }

vim.filetype.add({
  extension = {
    gohtml = "html", -- or "gotmpl" if you installed a template parser
  },
})

vim.opt.clipboard = "unnamedplus"
vim.env.PUPPETEER_EXECUTABLE_PATH = "/usr/bin/chromium"
vim.env.SNACKS_GHOSTTY = "true"
