return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = {
        exclude = { "python" },
      },
      servers = {
        basedpyright = {
          settings = {
            -- pyright = {
            --   disableOrganizeImports = true,
            -- },
            basedpyright = {
              typeCheckingMode = "basic",
              reportMissingSuperCall = false,
              reportUnknownMemberType = false,
              reportUnknownParameterType = false,
              reportUnknownVariableType = false,
              reportUnknownArgumentType = false,
              reportUnknownLambdaType = false,
              reportUnknownReturnType = false,
            },
          },
        },
      },
    },
  },
  {
    "GCBallesteros/jupytext.nvim",
    config = true,
    style = "markdown",
    output_extension = "md",
    force_ft = "markdown",
  },
  -- {
  --   "benlubas/molten-nvim",
  --   version = "^1.0.0", -- use version <2.0.0 to avoid breaking changes
  --   build = ":UpdateRemotePlugins",
  --   init = function()
  --     -- this is an example, not a default. Please see the readme for more configuration options
  --     vim.g.molten_output_win_max_height = 12
  --   end,
  -- },

  {
    "Vigemus/iron.nvim",
    config = function()
      local iron = require("iron.core")
      local view = require("iron.view")
      local common = require("iron.fts.common")
      local ll = require("iron.lowlevel")

      iron.setup({
        config = {
          scratch_repl = true,
          repl_definition = {
            sh = {
              command = { "zsh" },
            },
            python = {
              -- command = { "python3" }, -- or { "ipython", "--no-autoindent" }
              command = { "ipython", "--no-autoindent" },
              format = common.bracketed_paste_python,
              block_dividers = { "# %%", "#%%" },
              -- env = { PYTHON_BASIC_REPL = "1" }, --this is needed for python3.13 and up.
            },
          },
          repl_filetype = function(bufnr, ft)
            return ft
          end,
          dap_integration = true,
          preferred = { python = "bottom", sh = "bottom" },
          repl_open_cmd = view.bottom(40),
          -- repl_open_cmd = view.float({ width = 0.9, height = 0.9 }),
        },
        keymaps = {
          toggle_repl = "<space>rT", -- toggles the repl open and closed.
          restart_repl = "<space>rR", -- calls `IronRestart` to restart the repl
          send_motion = "<space>rs",
          visual_send = "<space>rs",
          send_file = "<space>rf",
          send_line = "<space>rl",
          exit = "<space>rq",
          clear = "<space>rc",
        },
        highlight = {
          italic = true,
        },
        ignore_blank_lines = true, -- ignore blank lines when sending visual select lines
      })
      vim.keymap.set("n", "<space>rz", function()
        local ft = vim.bo.filetype
        local repl_win = nil

        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local bufnr = vim.api.nvim_win_get_buf(win)
          local bft = vim.bo[bufnr].filetype
          local bt = vim.bo[bufnr].buftype
          if bt == "terminal" and bft == ft then
            repl_win = win
            break
          end
        end
        if repl_win then
          vim.cmd("IronHide")
        else
          vim.cmd("IronFocus")
        end
      end, { silent = true })

      vim.api.nvim_create_user_command("IronSendCell", function()
        local bufnr = 0
        local cur_line = vim.fn.line(".")
        local total = vim.fn.line("$")

        -- pattern to match "# %%" or "#%%"
        local cell_pat = "^%s*#%s*%%%%"

        -- find start: scan upward from cur_line to 1 for a marker
        local start = nil
        for ln = cur_line, 1, -1 do
          local text = vim.api.nvim_buf_get_lines(bufnr, ln - 1, ln, false)[1] or ""
          if text:match(cell_pat) then
            start = ln
            break
          end
        end
        if not start then
          start = 1
        end

        -- if cursor is on a marker, treat that marker as the start (VSCode behaviour)
        local curline_text = vim.api.nvim_buf_get_lines(bufnr, cur_line - 1, cur_line, false)[1] or ""
        if curline_text:match(cell_pat) then
          start = cur_line
        end

        -- find next marker after the current line (scan forward)
        local next_marker = nil
        for ln = cur_line + 1, total do
          local text = vim.api.nvim_buf_get_lines(bufnr, ln - 1, ln, false)[1] or ""
          if text:match(cell_pat) then
            next_marker = ln
            break
          end
        end

        local finish
        if next_marker then
          finish = next_marker - 1
        else
          finish = total
        end

        -- ensure finish is not before start
        if finish < start then
          finish = total
        end

        -- VSCode-style: skip the "# %%" marker line itself
        local send_start = start + 1
        if send_start > finish then
          -- empty cell (nothing between markers) -> move cursor to next marker if exists
          if next_marker then
            vim.fn.cursor(next_marker, 1)
          else
            vim.fn.cursor(total, 1)
          end
          return
        end

        -- get the lines to send and send them
        local lines = vim.api.nvim_buf_get_lines(bufnr, send_start - 1, finish, false)
        iron.send(nil, lines)
      end, {})

      -- Keymap to run cell
      vim.keymap.set("n", "<space><CR>", ":IronSendCell<CR>", { silent = true })
    end,
  },
}
