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
  {
    "benlubas/molten-nvim",
    version = "^1.0.0", -- use version <2.0.0 to avoid breaking changes
    build = ":UpdateRemotePlugins",
    init = function()
      -- this is an example, not a default. Please see the readme for more configuration options
      vim.g.molten_output_win_max_height = 12
    end,
  },
}
