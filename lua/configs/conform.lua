--type conform.options
-- You can view this list in vim with :help conform-formatters
-- repository: https://github.com/stevearc/conform.nvim
-- https://github.com/stevearc/conform.nvim?tab=readme-ov-file#formatters
local options = {
	lsp_fallback = true,

	formatters_by_ft = {
    ["*"] = { "codespell" },
		lua = { "stylua" },

		javascript = { "prettier" },
		css = { "prettier" },
		html = { "prettier" },

		sh = { "shfmt" },
    cpp = {"clang_format"},
    python = {"black"},
    cs = {"csharpier"},
    c = {"clang_format"}
	},

  -- adding same formatter for multiple filetypes can look too much work for some
  -- instead of the above code you could just use a loop! the config is just a table after all!

	-- format_on_save = {
	--   -- These options will be passed to conform.format()
	--   timeout_ms = 500,
	--   lsp_fallback = true,
	-- },
}

require("conform").setup(options)
