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
      { "<leader>vdl", "<cmd>DevcontainerLogsTail<cr>", desc = "Devcontainer Log Tail" },
      { "<leader>vdb", "<cmd>DevcontainerDockerBuild<cr>", desc = "Devcontainer Docker Build" },
      { "<leader>vda", "<cmd>DevcontainerAttach<cr>", desc = "Devcontainer Attach" },
      { "<leader>vds", "<cmd>DevcontainerStop<cr>", desc = "Devcontainer Stop" },
    },
    config = function()
      require("devcontainer").setup({})

      local function open_floating_terminal(cmd, title)
        local buf = vim.api.nvim_create_buf(false, true)
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

        vim.fn.termopen(cmd)
        vim.cmd.startinsert()
      end

      vim.api.nvim_create_user_command("DevcontainerLogsTail", function()
        local log_path = vim.fn.stdpath("cache") .. "/devcontainer.log"
        open_floating_terminal({ "tail", "-f", log_path }, " Devcontainer Logs ")
      end, { desc = "Tail devcontainer logs in a floating terminal" })

      vim.api.nvim_create_user_command("DevcontainerDockerBuild", function()
        local ok_parse, parse = pcall(require, "devcontainer.config_file.parse")
        local ok_config, devcontainer_config = pcall(require, "devcontainer.config")
        if not ok_parse or not ok_config then
          vim.notify("Unable to load devcontainer internals", vim.log.levels.ERROR)
          return
        end

        local ok_data, data = pcall(parse.parse_nearest_devcontainer_config)
        if not ok_data then
          vim.notify(data, vim.log.levels.ERROR)
          return
        end

        data = parse.fill_defaults(data)

        if not data.build or not data.build.dockerfile then
          vim.notify("Nearest devcontainer does not use a Dockerfile build", vim.log.levels.ERROR)
          return
        end

        local runtime = devcontainer_config.container_runtime
        if runtime == nil or runtime == "devcontainer-cli" then
          runtime = "docker"
        end

        open_floating_terminal(
          { runtime, "build", "-f", data.build.dockerfile, data.build.context },
          " Devcontainer Docker Build "
        )
      end, { desc = "Run raw docker build for the nearest devcontainer in a floating terminal" })
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
    config = true,
    keys = {
      { "<leader>gc", "<cmd>DiffviewOpen<cr>", desc = "DiffView Open" },
      { "<leader>gC", "<cmd>DiffviewClose<cr>", desc = "DiffView Close" },
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
