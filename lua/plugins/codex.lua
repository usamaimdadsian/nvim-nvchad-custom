local state = {
  buf = nil,
  win = nil,
  job = nil,
}

local M = {}

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
    title = " Codex CLI ",
    title_pos = "center",
  }
end

local function open_window(buf)
  state.win = vim.api.nvim_open_win(buf, true, calc_float())
  vim.wo[state.win].winblend = 0
end

local function start_codex()
  if vim.fn.executable("codex") ~= 1 then
    vim.notify("`codex` command not found in PATH", vim.log.levels.ERROR)
    return false
  end

  state.buf = vim.api.nvim_create_buf(false, true)
  vim.bo[state.buf].bufhidden = "hide"
  vim.bo[state.buf].filetype = "codex"

  open_window(state.buf)
  state.job = vim.fn.termopen({ "codex" }, {
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

  if not start_codex() then
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

  ensure_terminal()
end

return {
  {
    dir = vim.fn.stdpath("config"),
    name = "codex-cli-local",
    event = "VeryLazy",
    keys = {
      {
        "<leader>at",
        function()
          M.toggle()
        end,
        desc = "Codex Toggle",
      },
    },
    config = function()
      vim.api.nvim_create_user_command("CodexToggle", M.toggle, {})
    end,
  },
}
