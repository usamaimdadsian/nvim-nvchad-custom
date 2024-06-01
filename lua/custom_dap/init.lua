-- All adapters are in this link: https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation

local M = {}

M.dap_config =  function(_,_)
  -- require("core.utils").load_mappings("dap")

  -- local dap = require("dap")
  --
  -- dap.adapters.python = require("custom.dap.adapters.debugpy").adapter
  -- dap.configurations.python = require("custom.dap.adapters.debugpy").config
end

M.handlers = {
  function(config)
    require('mason-nvim-dap').default_setup(config)
  end,
  -- require("custom.dap.adapters.codelldb")(config)
  codelldb = require("custom_dap.adapters.codelldb")
}

M.ui = require("custom_dap.ui")


-- return handlers
return M
