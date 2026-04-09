local state = {
  compiledb = {},
  monitor = {
    autocmd = nil,
    buf = nil,
    env = nil,
    input_buf = nil,
    input_win = nil,
    win = nil,
    job = nil,
    line_ending = "LF",
    root = nil,
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

local function find_platformio_root(start)
  start = start or vim.api.nvim_buf_get_name(0)
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
      local opts = calc_float()
      opts.title = title
      reuse.win = vim.api.nvim_open_win(reuse.buf, true, opts)
      vim.cmd.startinsert()
      return
    end
  end

  local buf = vim.api.nvim_create_buf(false, true)
  local opts = calc_float()
  opts.title = title
  local win = vim.api.nvim_open_win(buf, true, opts)
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

local function line_ending_suffix(mode)
  if mode == "CRLF" then
    return "\r\n"
  end
  if mode == "LF" then
    return "\n"
  end
  return ""
end

local function monitor_title()
  local env = state.monitor.env and ("[" .. state.monitor.env .. "] ") or ""
  return state.monitor.title .. env .. "[" .. state.monitor.line_ending .. "] "
end

local function stop_monitor_job()
  if job_running(state.monitor.job) then
    pcall(vim.fn.chansend, state.monitor.job, "\003")
    pcall(vim.fn.jobstop, state.monitor.job)
  end
  state.monitor.job = nil
end

local function monitor_close(stop_job)
  if stop_job == nil then
    stop_job = false
  end
  if stop_job then
    stop_monitor_job()
  end
  if state.monitor.autocmd then
    pcall(vim.api.nvim_del_autocmd, state.monitor.autocmd)
    state.monitor.autocmd = nil
  end
  if is_valid_win(state.monitor.win) then
    vim.api.nvim_win_close(state.monitor.win, true)
  end
  if is_valid_win(state.monitor.input_win) then
    vim.api.nvim_win_close(state.monitor.input_win, true)
  end
  state.monitor.win = nil
  state.monitor.input_win = nil
end

local function follow_monitor_output()
  if is_valid_win(state.monitor.win) then
    pcall(vim.api.nvim_win_call, state.monitor.win, function()
      vim.cmd("normal! G")
    end)
  end
end

local function update_monitor_titles()
  if is_valid_win(state.monitor.win) then
    vim.api.nvim_win_set_config(state.monitor.win, vim.tbl_extend("force", vim.api.nvim_win_get_config(state.monitor.win), {
      title = monitor_title(),
    }))
  end
  if is_valid_win(state.monitor.input_win) then
    vim.api.nvim_win_set_config(
      state.monitor.input_win,
      vim.tbl_extend("force", vim.api.nvim_win_get_config(state.monitor.input_win), {
        title = " Serial Input [Enter=Send | Ctrl-L=Line Ending] ",
      })
    )
  end
end

local function cycle_monitor_line_ending()
  local current = state.monitor.line_ending
  if current == "None" then
    state.monitor.line_ending = "LF"
  elseif current == "LF" then
    state.monitor.line_ending = "CRLF"
  else
    state.monitor.line_ending = "None"
  end
  update_monitor_titles()
  vim.notify("PlatformIO monitor line ending: " .. state.monitor.line_ending, vim.log.levels.INFO)
end

local function send_monitor_input()
  if not job_running(state.monitor.job) then
    vim.notify("PlatformIO monitor is not running", vim.log.levels.WARN)
    return
  end
  if not is_valid_buf(state.monitor.input_buf) then
    return
  end

  local line = vim.api.nvim_buf_get_lines(state.monitor.input_buf, 0, 1, false)[1] or ""
  vim.fn.chansend(state.monitor.job, line .. line_ending_suffix(state.monitor.line_ending))
  vim.api.nvim_buf_set_lines(state.monitor.input_buf, 0, -1, false, { "" })

  if is_valid_win(state.monitor.input_win) then
    vim.api.nvim_set_current_win(state.monitor.input_win)
    vim.cmd.startinsert()
  end
end

local function setup_monitor_input_buffer()
  if is_valid_buf(state.monitor.input_buf) then
    return
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "hide"
  vim.bo[buf].filetype = "platformio-monitor-input"
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].swapfile = false
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "" })

  vim.keymap.set({ "n", "i" }, "<CR>", send_monitor_input, { buffer = buf, silent = true, desc = "Send serial input" })
  vim.keymap.set({ "n", "i" }, "<C-c>", function()
    monitor_close(true)
  end, { buffer = buf, silent = true, desc = "Stop serial monitor" })
  vim.keymap.set({ "n", "i" }, "<C-l>", cycle_monitor_line_ending, {
    buffer = buf,
    silent = true,
    desc = "Cycle line ending",
  })
  vim.keymap.set({ "n", "i" }, "<Esc>", monitor_close, { buffer = buf, silent = true, desc = "Close serial monitor" })
  vim.keymap.set("n", "q", monitor_close, { buffer = buf, silent = true, desc = "Close serial monitor" })
  vim.keymap.set({ "n", "i" }, "<C-w>k", function()
    if is_valid_win(state.monitor.win) then
      vim.api.nvim_set_current_win(state.monitor.win)
    end
  end, { buffer = buf, silent = true, desc = "Focus monitor output" })
  vim.keymap.set({ "n", "i" }, "<C-w>p", function()
    if is_valid_win(state.monitor.win) then
      vim.api.nvim_set_current_win(state.monitor.win)
    end
  end, { buffer = buf, silent = true, desc = "Focus monitor output" })

  state.monitor.input_buf = buf
end

local function open_monitor_windows()
  local base = calc_float()
  local input_height = 3
  local gap = 1

  local output_opts = vim.deepcopy(base)
  output_opts.height = base.height - input_height - gap
  output_opts.title = monitor_title()
  state.monitor.win = vim.api.nvim_open_win(state.monitor.buf, true, output_opts)

  local input_opts = vim.deepcopy(base)
  input_opts.height = input_height
  input_opts.row = base.row + output_opts.height + gap
  input_opts.title = " Serial Input [Enter=Send | Ctrl-L=Line Ending] "
  state.monitor.input_win = vim.api.nvim_open_win(state.monitor.input_buf, true, input_opts)

  vim.wo[state.monitor.input_win].number = false
  vim.wo[state.monitor.input_win].relativenumber = false
  vim.wo[state.monitor.input_win].signcolumn = "no"
  vim.wo[state.monitor.input_win].wrap = false

  vim.keymap.set({ "n", "t" }, "<Esc>", monitor_close, {
    buffer = state.monitor.buf,
    silent = true,
    desc = "Close serial monitor",
  })
  vim.keymap.set({ "n", "t" }, "<C-c>", function()
    monitor_close(true)
  end, {
    buffer = state.monitor.buf,
    silent = true,
    desc = "Stop serial monitor",
  })
  vim.keymap.set({ "n", "t" }, "q", monitor_close, {
    buffer = state.monitor.buf,
    silent = true,
    desc = "Close serial monitor",
  })
  vim.keymap.set({ "n", "t" }, "i", function()
    if is_valid_win(state.monitor.input_win) then
      vim.api.nvim_set_current_win(state.monitor.input_win)
      vim.cmd.startinsert()
    end
  end, {
    buffer = state.monitor.buf,
    silent = true,
    desc = "Focus serial input",
  })
  vim.keymap.set({ "n", "t" }, "<C-w>j", function()
    if is_valid_win(state.monitor.input_win) then
      vim.api.nvim_set_current_win(state.monitor.input_win)
      vim.cmd.startinsert()
    end
  end, {
    buffer = state.monitor.buf,
    silent = true,
    desc = "Focus serial input",
  })
  vim.keymap.set({ "n", "t" }, "<C-w>p", function()
    if is_valid_win(state.monitor.input_win) then
      vim.api.nvim_set_current_win(state.monitor.input_win)
      vim.cmd.startinsert()
    end
  end, {
    buffer = state.monitor.buf,
    silent = true,
    desc = "Focus serial input",
  })
  vim.keymap.set({ "n", "t" }, "o", follow_monitor_output, {
    buffer = state.monitor.buf,
    silent = true,
    desc = "Scroll monitor output to latest",
  })

  vim.wo[state.monitor.win].number = false
  vim.wo[state.monitor.win].relativenumber = false

  vim.api.nvim_set_current_win(state.monitor.input_win)
  vim.cmd.startinsert()
end

local function refresh_compiledb(root, cli, env, opts)
  opts = opts or {}
  if state.compiledb[root] == "running" then
    return
  end

  state.compiledb[root] = "running"
  vim.system({ cli, "run", "-e", env, "-t", "compiledb" }, { cwd = root }, function(result)
    vim.schedule(function()
      state.compiledb[root] = nil
      if result.code ~= 0 then
        return
      end

      local compile_commands = root .. "/compile_commands.json"
      if vim.uv.fs_stat(compile_commands) then
        state.compiledb[root] = "ready"
        for _, client in ipairs(vim.lsp.get_clients({ name = "clangd" })) do
          vim.lsp.stop_client(client.id, true)
        end
        local ft = vim.bo.filetype
        if ft == "c" or ft == "cpp" or ft == "objc" or ft == "objcpp" then
          vim.cmd("LspStart clangd")
        end
        if not opts.silent then
          vim.notify("PlatformIO compile database refreshed", vim.log.levels.INFO)
        end
      end
    end)
  end)
end

local function ensure_compiledb_for_buffer(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  if name == "" then
    return
  end

  local root, config_path = find_platformio_root(name)
  if not root or not config_path then
    return
  end

  if vim.uv.fs_stat(root .. "/compile_commands.json") then
    state.compiledb[root] = "ready"
    return
  end

  local cli = platformio_cli()
  if not cli then
    return
  end

  local envs = get_envs(config_path)
  if #envs ~= 1 then
    return
  end

  refresh_compiledb(root, cli, envs[1], { silent = true })
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

      if is_valid_win(state.monitor.win) or is_valid_win(state.monitor.input_win) then
        monitor_close(false)
        return
      end

      setup_monitor_input_buffer()
      state.monitor.env = env
      state.monitor.root = root

      if is_valid_buf(state.monitor.buf) then
        state.monitor.job = terminal_job(state.monitor.buf)
      end

      if job_running(state.monitor.job) then
        open_monitor_windows()
        update_monitor_titles()
        follow_monitor_output()
        return
      end

      state.monitor.buf = vim.api.nvim_create_buf(false, true)
      vim.bo[state.monitor.buf].bufhidden = "hide"
      vim.bo[state.monitor.buf].filetype = "platformio-monitor"

      open_monitor_windows()
      vim.api.nvim_set_current_win(state.monitor.win)
      state.monitor.job = vim.fn.termopen({ cli, "device", "monitor", "-e", env }, {
        cwd = root,
        on_exit = function()
          state.monitor.job = nil
        end,
      })
      state.monitor.autocmd = vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "TermEnter", "BufEnter" }, {
        buffer = state.monitor.buf,
        callback = function()
          vim.schedule(follow_monitor_output)
        end,
      })
      follow_monitor_output()
      vim.api.nvim_set_current_win(state.monitor.input_win)
      vim.cmd.startinsert()
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
      local augroup = vim.api.nvim_create_augroup("platformio_local", { clear = true })

      vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
        group = augroup,
        pattern = { "*.c", "*.cpp", "*.h", "*.hpp", "*.ino" },
        callback = function(args)
          ensure_compiledb_for_buffer(args.buf)
        end,
      })

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
