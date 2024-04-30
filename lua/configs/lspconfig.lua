local on_attach = require("nvchad.configs.lspconfig").on_attach
local capabilities = require("nvchad.configs.lspconfig").capabilities

local lspconfig = require "lspconfig"
local overrides = require("configs.overrides")

-- if you just want default config for the servers then put them in a table
-- local servers = {"html", "cssls", "tsserver", "clangd", "pyright", "texlab", "yamlls", "csharp_ls", "quick-lint-js", "lua_ls"}
local servers = overrides.mason_lsp

for _, lsp in ipairs(servers) do
  local lsp_config = {
    on_attach = on_attach,
    capabilities = capabilities,
  }

  lspconfig[lsp].setup(lsp_config)
end

-- lspconfig["omnisharp"] = {
--   handlers = {
--     ["textDocument/definition"] = function(...)
--         return require("omnisharp_extended").handler(...)
--       end,
--     },
--     keys = {
--       {
--         "gd",
--         function()
--           require("omnisharp_extended").telescope_lsp_definitions()
--         end,
--         desc = "Goto Definition",
--       },
--   },
--   enable_roslyn_analyzers = true,
--   organize_imports_on_format = true,
--   enable_import_completion = true,
-- }
--
-- lspconfig.pyright.setup { blabla}
