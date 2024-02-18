function dap_ui_config()
  local dap, dapui = require("dap"), require("dapui")

  dapui.setup()
  -- open / close ui windows automatically
  dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
  end
  dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
  end
  dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
  end
end
return dap_ui_config
