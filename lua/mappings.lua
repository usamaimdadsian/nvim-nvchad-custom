require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map({"i","v"}, "kj", "<ESC>")
map("n","<leader>fm",function() require("conform").format() end,{ desc = "Format" })
map("v",">",">gv",{ desc = "indent selected lines" }) -- indent selected lines
map("v","<","<gv",{ desc = "unindent selected lines" }) -- unindent selected lines
map("n","<leader>X","<cmd>bufdo bwipeout<cr>",{ desc = "Close all buffers" }) -- Close all buffers
map("n","<tab>","<cmd>bn<cr>",{ desc = "go to next buffer" }) -- go to next buffer
map("n","<s-tab>","<cmd>bp<cr>",{ desc = "go to previous buffer" }) -- go to previous buffer
map("n","<leader><tab>","<cmd>b#<cr>",{ desc = "go to previous buffer" }) -- go to previous buffer

