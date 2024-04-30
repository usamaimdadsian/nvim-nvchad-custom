require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "kj", "<ESC>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
-- ---@type MappingsTable

-- local lastActiveBuffer = nil

-- local M = {}

-- M.general = {
--   i = {
--     ["kj"] = {
--       "<Esc>",
--       "Escape to Normal Mode"
--     }
--   },

--   n = {

--     --  format with conform
--     ["<leader>fm"] = {
--       function()
--         require("conform").format()
--       end,
--       "formatting",
--     }

--   },
--   v = {
--     [">"] = { ">gv", "indent"},
--     ["kj"] = {
--       "<Esc>",
--       "Escape to Normal Mode"
--     }
--   },
-- }

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

-- M.dap = {
--   n = {
--     ["<leader>db"] = {
--       "<cmd> DapToggleBreakpoint <CR>",
--       "Add breakpoint at line",
--     },
--     ["<leader>dB"] = {
--       ":lua require'dap'.set_breakpoint(vim.fn.input('BreakPoint Condition: '))<CR>",
--       "Conditional Breakpoint",
--     },
--     ["<leader>dq"] = {
--       ":DapTerminate <CR>",
--       "Terminate Session",
--     },
--     ["<leader>dr"] = {
--       ":DapRestart <CR>",
--       "Restart Session",
--     },
--     ["<F5>"] = {
--       ":lua require'dap'.continue() <CR>",
--       "Start or continue the debugger"
--     },
--     ["<F2>"] = {
--       ":lua require'dap'.step_over() <CR>",
--       "Step Over"
--     },
--     ["<F3>"] = {
--       ":lua require'dap'.step_into() <CR>",
--       "Step Into"
--     },
--     ["<F4>"] = {
--       ":lua require'dap'.step_out() <CR>",
--       "Step Out"
--     }
--   },
-- }

-- -- more keybinds!

-- return M
