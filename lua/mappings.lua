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


-- Dap Mapping
map("n","<leader>db","<cmd> DapToggleBreakpoint <CR>",{desc = "Add breakpoint at line" })
map("n","<leader>dB",":lua require'dap'.set_breakpoint(vim.fn.input('BreakPoint Condition: '))<CR>",{desc = "Conditional Breakpoint" })
map("n","<leader>dq",":DapTerminate <CR>",{desc = "Terminate Session" })
map("n","<leader>dr",":DapRestart <CR>",{desc = "Restart Session" })
map("n","<F5>",":lua require'dap'.continue() <CR>",{desc = "Start or continue the debugger" })
map("n","<F2>",":lua require'dap'.step_over() <CR>",{desc = "Step Over" })
map("n","<F3>",":lua require'dap'.step_into() <CR>",{desc = "Step Into" })
map("n","<F4>",":lua require'dap'.step_out() <CR>",{desc = "Step Out" })
--     }

-- M.tabufline = {
--   plugin = true,
--   n = {
--     ["<leader>X"] = {
--       function()
--         require("nvchad.tabufline").closeAllBufs()
--       end,
--       "Close buffer",
--     },
--     ["<leader><tab>"] = {"<C-^>","toggle buffer"}
--   }
-- }

