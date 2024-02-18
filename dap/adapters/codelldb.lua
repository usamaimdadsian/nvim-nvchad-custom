
local function compile_and_run_cpp()
  local file = vim.fn.expand("%:p") -- Get the full path of the current file
  local exe_name = vim.fn.expand("%:t:r") -- Get the file name without extension
  local workspace_folder = vim.fn.getcwd() -- Get the current workspace folder
  local relative_file_path = vim.fn.fnamemodify(file, ":~:.") -- Get the relative file path

  -- Calculate the path for the bin folder
  local bin_folder = workspace_folder .. "/bin/" .. vim.fn.fnamemodify(relative_file_path, ":h")

  -- Ensure the bin folder exists, create it if necessary
  vim.fn.mkdir(bin_folder, "p")

  -- Compile command with output directory
  local cmd = "clang++ -g " .. file .. " -o " .. bin_folder .. "/" .. exe_name

  -- Run the compile command in shell
  vim.api.nvim_command("! " .. cmd)

  local run_cmd = "! " .. bin_folder .. "/" .. exe_name -- Command to run the executable
  vim.api.nvim_command(run_cmd) -- Run the executable
  return bin_folder .. "/" .. exe_name
end

local codelldb = function(config)
  config.configurations = {
    {
      name = 'LLDB: Launch',
      type = 'codelldb',
      request = 'launch',
      program = function()
        return compile_and_run_cpp();
      end,
      cwd = '${workspaceFolder}',
      stopOnEntry = false,
      args = {},
      console = 'integratedTerminal',
    },
  }
  require('mason-nvim-dap').default_setup(config) -- don't forget this!
end

return codelldb
