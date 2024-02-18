local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

local lspconfig = require "lspconfig"

-- if you just want default config for the servers then put them in a table
local servers = {"html", "cssls", "tsserver", "clangd", "pyright", "texlab"}

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end

lspconfig["omnisharp"] = {
  handlers = {
    ["textDocument/definition"] = function(...)
        return require("omnisharp_extended").handler(...)
      end,
    },
    keys = {
      {
        "gd",
        function()
          require("omnisharp_extended").telescope_lsp_definitions()
        end,
        desc = "Goto Definition",
      },
  },
  enable_roslyn_analyzers = true,
  organize_imports_on_format = true,
  enable_import_completion = true,
}
--
-- lspconfig.pyright.setup { blabla}
