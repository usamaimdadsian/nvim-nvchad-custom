-- This file needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/ui/blob/v2.5/lua/nvconfig.lua

---@type ChadrcConfig
local M = {}

M.ui = {
  theme = "tokyonight",
  theme_toggle = { "onedark", "one_light" },
  transparency = true,

  hl_override = {
    Normal = { bg = "NONE" },
    NormalNC = { bg = "NONE" },
    SignColumn = { bg = "NONE" },
    VertSplit = { bg = "NONE" },
    NonText = { bg = "NONE" },
  },

	-- hl_override = {
	-- 	Comment = { italic = true },
	-- 	["@comment"] = { italic = true },
	-- },
}

return M
