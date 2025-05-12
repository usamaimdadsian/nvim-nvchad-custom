-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = LazyVim.safe_keymap_set

map("i", "kj", "<Esc>", { desc = "Go to normal mode" })
map("v", "kj", "<Esc>", { desc = "Go to normal mode" })
map("n", "<leader>bn", ":enew<CR>", { desc = "New buffer" })
