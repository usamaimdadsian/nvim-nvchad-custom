local state = {
  monitor = {
    buf = nil,
    win = nil,
    job = nil,
    title = " PlatformIO Serial Monitor ",
  },
}

local function is_valid_buf(buf)
  return buf and vim.api.nvim_buf_is_valid(buf)
end

local function is_valid_win(win)
  return win and vim.api.nvim_win_is_valid(win)
end

local function terminal_job(buf)
  if not is_valid_buf(buf) then
    return nil
  end
  return vim.b[buf].terminal_job_id
end

local function job_running(job)
  return job and job > 0 and vim.fn.jobwait({ job }, 0)[1] == -1
end

local function calc_float()
  local width = math.floor(vim.o.columns * 0.9)
  local height = math.floor(vim.o.lines * 0.85)
  return {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal",
    border = "rounded",
    title_pos = "center",
  }
end

local function open_float(buf, title)
  local opts = calc_float()
  opts.title = title
  local win = vim.api.nvim_open_win(buf, true, opts)

  local function close()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  vim.keymap.set({ "n", "t" }, "<Esc>", close, { buffer = buf, silent = true, desc = "Close floating terminal" })
  vim.keymap.set({ "n", "t" }, "q", close, { buffer = buf, silent = true, desc = "Close floating terminal" })
  return win
end

local function find_platformio_root()
  local start = vim.api.nvim_buf_get_name(0)
  if start == "" then
    start = vim.fn.getcwd()
  end

  local found = vim.fs.find("platformio.ini", {
    upward = true,
    path = vim.fs.dirname(start),
    stop = vim.loop.os_homedir(),
  })[1]

  if not found then
    return nil
  end

  return vim.fs.dirname(found), found
end

local function platformio_cli()
  if vim.fn.executable("pio") == 1 then
    return "pio"
  end
  if vim.fn.executable("platformio") == 1 then
    return "platformio"
  end
  return nil
end

local function get_envs(config_path)
  local lines = vim.fn.readfile(config_path)
  local envs = {}

  for _, line in ipairs(lines) do
    local env = line:match("^%[env:([^%]]+)%]$")
    if env then
      table.insert(envs, env)
    end
  end

  return envs
end

local function with_project(callback)
  local root, config_path = find_platformio_root()
  if not root then
    vim.notify("No platformio.ini found in current project", vim.log.levels.ERROR)
    return
  end

  local cli = platformio_cli()
  if not cli then
    vim.notify("PlatformIO CLI not found in PATH (`pio` or `platformio`)", vim.log.levels.ERROR)
    return
  end

  callback(root, config_path, cli)
end

local function select_env(config_path, callback)
  local envs = get_envs(config_path)
  if #envs == 0 then
    vim.notify("No PlatformIO environments found in platformio.ini", vim.log.levels.ERROR)
    return
  end
  if #envs == 1 then
    callback(envs[1])
    return
  end

  vim.ui.select(envs, {
    prompt = "Select PlatformIO environment",
  }, callback)
end

local function open_command(cmd, title, root, reuse)
  if reuse and is_valid_win(reuse.win) then
    vim.api.nvim_set_current_win(reuse.win)
    return
  end

  if reuse and is_valid_buf(reuse.buf) then
    reuse.job = terminal_job(reuse.buf)
    if job_running(reuse.job) then
      reuse.win = open_float(reuse.buf, title)
      vim.cmd.startinsert()
      return
    end
  end

  local buf = vim.api.nvim_create_buf(false, true)
  local win = open_float(buf, title)
  local job = vim.fn.termopen(cmd, {
    cwd = root,
    on_exit = function()
      if reuse then
        reuse.job = nil
      end
    end,
  })
  vim.cmd.startinsert()

  if reuse then
    reuse.buf = buf
    reuse.win = win
    reuse.job = job
  end
end

local function refresh_compiledb(root, cli, env)
  vim.system({ cli, "run", "-e", env, "-t", "compiledb" }, { cwd = root }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        return
      end

      local compile_commands = root .. "/compile_commands.json"
      if vim.uv.fs_stat(compile_commands) then
        for _, client in ipairs(vim.lsp.get_clients({ name = "clangd" })) do
          vim.lsp.stop_client(client.id, true)
        end
        local ft = vim.bo.filetype
        if ft == "c" or ft == "cpp" or ft == "objc" or ft == "objcpp" then
          vim.cmd("LspStart clangd")
        end
        vim.notify("PlatformIO compile database refreshed", vim.log.levels.INFO)
      end
    end)
  end)
end

local function run_command(args, title)
  with_project(function(root, config_path, cli)
    select_env(config_path, function(env)
      if not env then
        return
      end

      local cmd = { cli, "run", "-e", env }
      vim.list_extend(cmd, args)
      open_command(cmd, title .. " [" .. env .. "] ", root)
      refresh_compiledb(root, cli, env)
    end)
  end)
end

local function serial_monitor()
  with_project(function(root, config_path, cli)
    select_env(config_path, function(env)
      if not env then
        return
      end

      open_command(
        { cli, "device", "monitor", "-e", env },
        state.monitor.title .. "[" .. env .. "] ",
        root,
        state.monitor
      )
    end)
  end)
end

return {
  {
    dir = vim.fn.stdpath("config"),
    name = "platformio-local",
    event = "VeryLazy",
    keys = {
      {
        "<leader>hb",
        function()
          run_command({}, " PlatformIO Build ")
        end,
        desc = "PlatformIO Build",
      },
      {
        "<leader>hu",
        function()
          run_command({ "-t", "upload" }, " PlatformIO Upload ")
        end,
        desc = "PlatformIO Upload",
      },
      {
        "<leader>hm",
        function()
          serial_monitor()
        end,
        desc = "PlatformIO Monitor",
      },
    },
    config = function()
      vim.api.nvim_create_user_command("PlatformIOBuild", function()
        run_command({}, " PlatformIO Build ")
      end, { desc = "Build the nearest PlatformIO project" })

      vim.api.nvim_create_user_command("PlatformIOUpload", function()
        run_command({ "-t", "upload" }, " PlatformIO Upload ")
      end, { desc = "Upload the nearest PlatformIO project" })

      vim.api.nvim_create_user_command("PlatformIOMonitor", function()
        serial_monitor()
      end, { desc = "Open PlatformIO serial monitor" })
    end,
  },
}
