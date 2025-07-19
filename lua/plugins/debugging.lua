local function handle_continue()
  local cwd = vim.fn.getcwd()
  local vscode_dir = cwd .. "/.vscode"
  local launch_path = vscode_dir .. "/launch.json"

  -- Create .vscode directory if it doesn't exist
  if vim.fn.isdirectory(vscode_dir) == 0 then
    vim.fn.mkdir(vscode_dir, "p")
  end

  -- Create launch.json file if it doesn't exist
  if vim.fn.filereadable(launch_path) == 0 then
    local file = io.open(launch_path, "w")
    if file then
      file:write([[
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Run Project",
      "type": "pwa-node/debugpy/lldb",
      "request": "launch",
      "program": "${workspaceFolder}/",
      "cwd": "${workspaceFolder}",
      "console": "integratedTerminal"
    }
  ]
}
      ]])
      file:close()
    else
      vim.notify("Failed to create launch.json", vim.log.levels.ERROR)
      return
    end
    -- Open launch.json in a buffer
    vim.cmd("edit " .. vim.fn.fnameescape(launch_path))
  else
    require("dap").continue()
  end
end

return {
  {
    "Weissle/persistent-breakpoints.nvim",
    event = "BufReadPost", -- load breakpoints when reading files
    dependencies = { "mfussenegger/nvim-dap" }, -- make sure DAP is installed
    config = function()
      require("persistent-breakpoints").setup({
        load_breakpoints_event = { "BufReadPost" },
      })

      local opts = { noremap = true, silent = true }
      local keymap = vim.api.nvim_set_keymap
      _G.handle_continue = handle_continue

      keymap("n", "<leader>db", "<cmd>lua require('persistent-breakpoints.api').toggle_breakpoint()<CR>", opts)
      keymap("n", "<leader>dB", "<cmd>lua require('persistent-breakpoints.api').set_conditional_breakpoint()<CR>", opts)
      keymap("n", "<leader>dc", "<cmd>lua handle_continue()<CR>", opts)
      -- keymap("n", "<leader>dl", "<cmd>lua require('persistent-breakpoints.api').set_log_point()<CR>", opts)
      -- keymap("n", "<leader>dC", "<cmd>lua require('persistent-breakpoints.api').clear_all_breakpoints()<CR>", opts)
    end,
  },
  {
    "mfussenegger/nvim-dap",
    keys = {
      {
        "<leader>do",
        function()
          require("dap").step_over()
        end,
        desc = "Step Over",
      },
      {
        "<leader>dO",
        function()
          require("dap").step_out()
        end,
        desc = "Step Out",
      },
    },
  },
}
