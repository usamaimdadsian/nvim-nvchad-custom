local state = {
  buf = nil,
  win = nil,
  job = nil,
  agent = nil,
}

local M = {}

local agents = {
  { label = "Codex", cmd = "codex" },
  { label = "Claude Code", cmd = "claude" },
  { label = "OpenCode", cmd = "opencode" },
}

local function is_valid_buf(buf)
  return buf and vim.api.nvim_buf_is_valid(buf)
end

local function is_valid_win(win)
  return win and vim.api.nvim_win_is_valid(win)
end

local function term_job(buf)
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
    title = " Agent CLI ",
    title_pos = "center",
  }
end

local function open_window(buf)
  state.win = vim.api.nvim_open_win(buf, true, calc_float())
  vim.wo[state.win].winblend = 0
end

local function select_agent(callback)
  if state.agent then
    callback(state.agent)
    return
  end

  vim.ui.select(agents, {
    prompt = "Select agent",
    format_item = function(item)
      return item.label
    end,
  }, function(choice)
    if not choice then
      return
    end
    state.agent = choice
    callback(choice)
  end)
end

local function start_agent()
  if not state.agent then
    return false
  end

  if vim.fn.executable(state.agent.cmd) ~= 1 then
    vim.notify("`" .. state.agent.cmd .. "` command not found in PATH", vim.log.levels.ERROR)
    return false
  end

  state.buf = vim.api.nvim_create_buf(false, true)
  vim.bo[state.buf].bufhidden = "hide"
  vim.bo[state.buf].filetype = "agent"

  open_window(state.buf)
  state.job = vim.fn.termopen({ state.agent.cmd }, {
    on_exit = function()
      state.job = nil
    end,
  })

  vim.cmd.startinsert()
  return true
end

local function ensure_terminal()
  if is_valid_win(state.win) then
    vim.api.nvim_set_current_win(state.win)
    state.job = term_job(state.buf)
    if not job_running(state.job) then
      vim.api.nvim_win_close(state.win, true)
      state.win = nil
      state.buf = nil
      return ensure_terminal()
    end
    vim.cmd.startinsert()
    return state.buf, state.job
  end

  if is_valid_buf(state.buf) then
    state.job = term_job(state.buf)
    if not job_running(state.job) then
      state.buf = nil
      return ensure_terminal()
    end
    open_window(state.buf)
    vim.cmd.startinsert()
    return state.buf, state.job
  end

  if not start_agent() then
    return nil, nil
  end

  return state.buf, state.job
end

function M.toggle()
  if is_valid_win(state.win) then
    vim.api.nvim_win_close(state.win, true)
    state.win = nil
    return
  end

  select_agent(function()
    ensure_terminal()
  end)
end

function M.select()
  vim.ui.select(agents, {
    prompt = "Select agent",
    format_item = function(item)
      return item.label
    end,
  }, function(choice)
    if not choice then
      return
    end
    state.agent = choice

    if is_valid_win(state.win) then
      vim.api.nvim_win_close(state.win, true)
      state.win = nil
    end

    state.buf = nil
    state.job = nil
  end)
end

return {
  {
    dir = vim.fn.stdpath("config"),
    name = "agent-cli-local",
    event = "VeryLazy",
    keys = {
      {
        "<leader>at",
        function()
          M.toggle()
        end,
        desc = "Agent Toggle",
      },
    },
    config = function()
      vim.api.nvim_create_user_command("AgentToggle", M.toggle, {})
      vim.api.nvim_create_user_command("AgentSelect", M.select, {})
    end,
  },
}
