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

      iron.setup({
        config = {
          -- Whether a repl should be discarded or not
          scratch_repl = true,
          -- Your repl definitions come here
          repl_definition = {
            sh = {
              -- Can be a table or a function that
              -- returns a table (see below)
              command = { "zsh" },
            },
            python = {
              command = { "python3" }, -- or { "ipython", "--no-autoindent" }
              format = common.bracketed_paste_python,
              block_dividers = { "# %%", "#%%" },
              env = { PYTHON_BASIC_REPL = "1" }, --this is needed for python3.13 and up.
            },
          },
          -- set the file type of the newly created repl to ft
          -- bufnr is the buffer id of the REPL and ft is the filetype of the
          -- language being used for the REPL.
          repl_filetype = function(bufnr, ft)
            return ft
            -- or return a string name such as the following
            -- return "iron"
          end,
          -- Send selections to the DAP repl if an nvim-dap session is running.
          dap_integration = true,
          -- How the repl window will be displayed
          -- See below for more information
          repl_open_cmd = view.bottom(40),

          -- repl_open_cmd can also be an array-style table so that multiple
          -- repl_open_commands can be given.
          -- When repl_open_cmd is given as a table, the first command given will
          -- be the command that `IronRepl` initially toggles.
          -- Moreover, when repl_open_cmd is a table, each key will automatically
          -- be available as a keymap (see `keymaps` below) with the names
          -- toggle_repl_with_cmd_1, ..., toggle_repl_with_cmd_k
          -- For example,
          --
          -- repl_open_cmd = {
          --   view.split.vertical.rightbelow("%40"), -- cmd_1: open a repl to the right
          --   view.split.rightbelow("%25")  -- cmd_2: open a repl below
          -- }
        },
        -- Iron doesn't set keymaps by default anymore.
        -- You can set them here or manually add keymaps to the functions in iron.core
        keymaps = {
          toggle_repl = "<space>rz", -- toggles the repl open and closed.
          -- If repl_open_command is a table as above, then the following keymaps are
          -- available
          -- toggle_repl_with_cmd_1 = "<space>rv",
          -- toggle_repl_with_cmd_2 = "<space>rh",
          restart_repl = "<space>rR", -- calls `IronRestart` to restart the repl
          send_motion = "<space>rs",
          visual_send = "<space>rs",
          send_file = "<space>rf",
          send_line = "<space>rl",
          exit = "<space>rq",
          clear = "<space>rc",
        },
        -- If the highlight is on, you can change how it looks
        -- For the available options, check nvim_set_hl
        highlight = {
          italic = true,
        },
        ignore_blank_lines = true, -- ignore blank lines when sending visual select lines
      })

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
