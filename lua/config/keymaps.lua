-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = LazyVim.safe_keymap_set

local function project_root()
  return require("config.project_root").root()
end

map("i", "kj", "<Esc>", { desc = "Go to normal mode" })
map("v", "kj", "<Esc>", { desc = "Go to normal mode" })
map("t", "jk", [[<C-\><C-n>]], { desc = "Go to normal mode" })
map("n", "<leader>bn", ":enew<CR>", { desc = "New buffer" })
map("n", "<leader>z", ":ZenMode<CR>", { desc = "toggle zen mode (zoom in current window/buffer)" })
map("n", "<leader>dU", function()
  require("dapui").toggle({ reset = true })
end, { desc = "DAP UI reset" })
map({ "n", "t" }, "<C-/>", function()
  Snacks.terminal(nil, { cwd = project_root() })
end, { desc = "Terminal (Project Root)" })
map({ "n", "t" }, "<C-_>", function()
  Snacks.terminal(nil, { cwd = project_root() })
end, { desc = "which_key_ignore" })
map("n", "<leader>ft", function()
  Snacks.terminal(nil, { cwd = project_root() })
end, { desc = "Terminal (Project Root)" })
