require "nvchad.options"

-- add yours here!

local opt = vim.opt
opt.scrolloff = 8
opt.relativenumber = true
opt.clipboard = "unnamedplus"
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true
opt.spelllang = 'en_us'
opt.spell = true
opt.termguicolors = true

vim.cmd [[hi Normal guibg=NONE ctermbg=NONE]]
vim.cmd [[hi NonText guibg=NONE ctermbg=NONE]]
vim.cmd [[hi SignColumn guibg=NONE ctermbg=NONE]]
vim.cmd [[hi NormalNC guibg=NONE ctermbg=NONE]]
vim.cmd [[hi VertSplit guibg=NONE ctermbg=NONE]]
