return {
  {
    "mg979/vim-visual-multi",
    event = "VeryLazy",
  },
  {
    "folke/snacks.nvim",
    opts = {
      image = { enabled = true },
      math = {
        latex = { font_size = "normalsize" },
      },
    },
  },
  {
    "nvim-neotest/neotest",
    dependencies = { "nvim-neotest/nvim-nio" },
  },
  {
    "folke/zen-mode.nvim",
  },
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({})
      -- surr*ound_words             ysiw)           (surround_words)
      -- *make strings               ys$"            "make strings"
      -- [delete ar*ound me!]        ds]             delete around me!
      -- remove <b>HTML t*ags</b>    dst             remove HTML tags
      -- 'change quot*es'            cs'"            "change quotes"
      -- <b>or tag* types</b>        csth1<CR>       <h1>or tag types</h1>
      -- delete(functi*on calls)     dsf             function calls
    end,
  },
  {
    "m4xshen/hardtime.nvim",
    lazy = false,
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {},
  },
  {
    "https://codeberg.org/esensar/nvim-dev-container",
    dependencies = "nvim-treesitter/nvim-treesitter",
    event = "VeryLazy",
    keys = {
      { "<leader>vdl", "<cmd>DevcontainerDockerBuildLogs<cr>", desc = "Devcontainer Build Output" },
      { "<leader>vdb", "<cmd>DevcontainerDockerBuild<cr>", desc = "Devcontainer Docker Build" },
      { "<leader>vda", "<cmd>DevcontainerAttach<cr>", desc = "Devcontainer Attach" },
      { "<leader>vds", "<cmd>DevcontainerStop<cr>", desc = "Devcontainer Stop" },
    },
    config = function()
      require("devcontainer").setup({})

      local build_state = {
        buf = nil,
        win = nil,
      }

      local function is_valid_buf(buf)
        return buf and vim.api.nvim_buf_is_valid(buf)
      end

      local function is_valid_win(win)
        return win and vim.api.nvim_win_is_valid(win)
      end

      local function resolve_devcontainer_data()
        local ok_parse, parse = pcall(require, "devcontainer.config_file.parse")
        if not ok_parse then
          vim.notify("Unable to load devcontainer parser", vim.log.levels.ERROR)
          return nil
        end

        local ok_data, data = pcall(parse.parse_nearest_devcontainer_config)
        if not ok_data then
          vim.notify(data, vim.log.levels.ERROR)
          return nil
        end

        return parse.fill_defaults(data)
      end

      local function open_floating_terminal(buf, title)
        local width = math.floor(vim.o.columns * 0.9)
        local height = math.floor(vim.o.lines * 0.85)

        local win = vim.api.nvim_open_win(buf, true, {
          relative = "editor",
          width = width,
          height = height,
          col = math.floor((vim.o.columns - width) / 2),
          row = math.floor((vim.o.lines - height) / 2),
          style = "minimal",
          border = "rounded",
          title = title,
          title_pos = "center",
        })

        local close = function()
          if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
          end
        end

        vim.keymap.set({ "n", "t" }, "<Esc>", close, { buffer = buf, silent = true, desc = "Close floating terminal" })
        vim.keymap.set({ "n", "t" }, "q", close, { buffer = buf, silent = true, desc = "Close floating terminal" })
        return win
      end

      local function create_floating_terminal(cmd, title)
        local buf = vim.api.nvim_create_buf(false, true)
        local win = open_floating_terminal(buf, title)

        vim.fn.termopen(cmd)
        vim.cmd.startinsert()
        return buf, win
      end

      local function show_last_build_output()
        if is_valid_win(build_state.win) then
          vim.api.nvim_set_current_win(build_state.win)
          return
        end

        if not is_valid_buf(build_state.buf) then
          vim.notify("No docker build output available yet", vim.log.levels.WARN)
          return
        end

        build_state.win = open_floating_terminal(build_state.buf, " Devcontainer Docker Build ")
        vim.cmd.startinsert()
      end

      vim.api.nvim_create_user_command("DevcontainerDockerBuildLogs", show_last_build_output, {
        desc = "Show last docker build output in a floating terminal",
      })

      vim.api.nvim_create_user_command("DevcontainerDockerBuild", function()
        local ok_config, devcontainer_config = pcall(require, "devcontainer.config")
        if not ok_config then
          vim.notify("Unable to load devcontainer internals", vim.log.levels.ERROR)
          return
        end

        local data = resolve_devcontainer_data()
        if not data then
          return
        end

        if not data.build or not data.build.dockerfile then
          vim.notify("Nearest devcontainer does not use a Dockerfile build", vim.log.levels.ERROR)
          return
        end

        local runtime = devcontainer_config.container_runtime
        if runtime == nil or runtime == "devcontainer-cli" then
          runtime = "docker"
        end

        build_state.buf, build_state.win = create_floating_terminal(
          { runtime, "build", "-f", data.build.dockerfile, data.build.context },
          " Devcontainer Docker Build "
        )
      end, { desc = "Run raw docker build for the nearest devcontainer in a floating terminal" })

      vim.api.nvim_del_user_command("DevcontainerAttach")
      vim.api.nvim_create_user_command("DevcontainerAttach", function()
        local data = resolve_devcontainer_data()
        if not data then
          return
        end

        local commands = require("devcontainer.commands")
        local status = require("devcontainer.status")

        if data.dockerComposeFile then
          commands.attach_auto("devcontainer", "nvim")
          return
        end

        if data.build and data.build.dockerfile then
          local image = status.find_image({ source_dockerfile = data.build.dockerfile })
          local container = image and status.find_container({ image_id = image.image_id }) or nil

          if container then
            commands.attach_auto("devcontainer", "nvim")
          else
            vim.notify("No tracked devcontainer is running. Starting and attaching...", vim.log.levels.INFO)
            commands.start_auto(nil, true)
          end
          return
        end

        if data.image then
          local container = status.find_container({ image_id = data.image })

          if container then
            commands.attach_auto("devcontainer", "nvim")
          else
            vim.notify("No tracked devcontainer is running. Starting and attaching...", vim.log.levels.INFO)
            commands.start_auto(nil, true)
          end
          return
        end

        vim.notify("No supported devcontainer target found", vim.log.levels.ERROR)
      end, {
        nargs = 0,
        desc = "Attach to a running devcontainer or start and attach if needed",
      })
    end,
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    keys = {
      -- swap behavior
      { "<leader>e", "<leader>fE", desc = "Explorer NeoTree (Root Dir)", remap = true },
      { "<leader>E", "<leader>fe", desc = "Explorer NeoTree (cwd)", remap = true },
    },
  },
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
    config = function()
      require("diffview").setup({})

      local function git_lines(args)
        local cmd = { "git", "-C", vim.fn.getcwd() }
        vim.list_extend(cmd, args)

        local result = vim.system(cmd, { text = true }):wait()
        if result.code ~= 0 then
          local err = vim.trim(result.stderr or result.stdout or "Git command failed")
          return nil, err
        end

        local output = vim.trim(result.stdout or "")
        if output == "" then
          return {}, nil
        end

        return vim.split(output, "\n", { trimempty = true }), nil
      end

      local function select_commit(prompt, commits, on_choice)
        vim.ui.select(commits, {
          prompt = prompt,
          format_item = function(item)
            return item.display
          end,
        }, on_choice)
      end

      local function compare_commits()
        local lines, err = git_lines({ "log", "--oneline", "--decorate", "-n", "100" })
        if not lines then
          vim.notify(err, vim.log.levels.ERROR)
          return
        end

        local commits = {}
        for _, line in ipairs(lines) do
          local hash = line:match("^(%w+)")
          if hash then
            table.insert(commits, { hash = hash, display = line })
          end
        end

        if #commits == 0 then
          vim.notify("No commits found", vim.log.levels.WARN)
          return
        end

        select_commit("Base commit", commits, function(base)
          if not base then
            return
          end

          select_commit("Target commit", commits, function(target)
            if not target then
              return
            end

            if base.hash == target.hash then
              vim.notify("Choose two different commits", vim.log.levels.WARN)
              return
            end

            vim.cmd("DiffviewOpen " .. base.hash .. ".." .. target.hash)
          end)
        end)
      end

      vim.api.nvim_create_user_command("DiffviewCompareCommits", compare_commits, {
        desc = "Compare two commits in Diffview",
      })
    end,
    keys = {
      { "<leader>gc", "<cmd>DiffviewOpen<cr>", desc = "DiffView Open" },
      { "<leader>gC", "<cmd>DiffviewClose<cr>", desc = "DiffView Close" },
      { "<leader>ge", "<cmd>DiffviewCompareCommits<cr>", desc = "DiffView Compare Commits" },
    },
  },
  -- {
  --   "yetone/avante.nvim",
  --   opts = function(_, opts)
  --     -- Change only the provider
  --     opts.provider = "ollama"
  --
  --     opts.max_tokens = 256
  --     opts.debounce = 400
  --     opts.context_lines = 80
  --
  --     -- Add / override only ollama config
  --     opts.providers = opts.providers or {}
  --     opts.providers.ollama = {
  --       model = "deepseek-coder:1.3b",
  --       is_env_set = require("avante.providers.ollama").check_endpoint_alive,
  --     }
  --   end,
  -- },
  --
}
