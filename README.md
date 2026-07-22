# 💤 LazyVim

A starter template for [LazyVim](https://github.com/LazyVim/LazyVim).
Refer to the [documentation](https://lazyvim.github.io/installation) to get started.

## Obsidian workspaces

The Obsidian integration is enabled only when at least one workspace is configured. Systems without an Obsidian vault can leave it unconfigured; the plugin will remain disabled for Markdown files.

### Local configuration

Copy the ignored example file and update the workspace name and path:

```sh
cp lua/config/local.example.lua lua/config/local.lua
```

```lua
return {
  obsidian_workspaces = {
    {
      name = "personal",
      path = vim.fn.expand("~/path/to/obsidian/vault"),
    },
  },
}
```

Multiple workspace entries can be added to the list. To explicitly disable Obsidian on a system that has related environment variables, use:

```lua
return {
  obsidian_workspaces = {},
}
```

### Environment variables

For a single vault, configure the workspace without a local Lua file:

```sh
export OBSIDIAN_VAULT="$HOME/path/to/obsidian/vault"
export OBSIDIAN_VAULT_NAME="personal" # optional; defaults to personal
```

If `lua/config/local.lua` defines `obsidian_workspaces`, that list takes precedence over the environment variables.
