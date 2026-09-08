# Neovim Configuration

A personal [Neovim](https://neovim.io/) configuration built on [LazyVim](https://github.com/LazyVim/LazyVim), extended with custom modules for embedded (PlatformIO) development, AI agent CLIs, devcontainers, and an Obsidian workflow.

> The repository name is historical — this is a LazyVim-based config, not nvchad.

## Features at a glance

- **LazyVim base** with language extras for C/C++ (clangd), Go, Rust, Python,
  TypeScript, PHP, Java, SQL, Docker, Git, Markdown, TeX, and more
- **Submodule-aware project root detection** — terminals open in the correct
  repo root even inside git submodules of a monorepo
- **AI agent terminal** — run `codex`, `claude`, `opencode`, or `pi` in a
  floating window with one keypress
- **PlatformIO module** — build, upload, and a custom serial monitor (with a
  separate input line and CRLF/LF switching), plus automatic
  `compile_commands.json` generation for clangd
- **Devcontainer support** — build/attach/stop from inside Neovim, with a
  patched fork that supports `${devcontainerId}` in mount paths
- **Debugging (DAP)** — persistent breakpoints across sessions, step/continue
  keymaps, and auto-created `launch.json` scaffolding
- **Python tooling** — basedpyright with tuned diagnostics, jupytext for
  notebook ↔ markdown, and [iron.nvim](https://github.com/Vigemus/iron.nvim)
  REPLs with VSCode-style cell execution
- **Obsidian integration** — vault workspaces, wiki-link mappings, and
  frontmatter tags derived from folder structure on save
- **Git tooling** — Diffview with an interactive two-commit comparison command

## Requirements

| Requirement | Needed for |
| --- | --- |
| Neovim ≥ 0.10 (developed on 0.12) | everything |
| `git` | plugin bootstrap, git tools, project root detection |
| [PlatformIO CLI](https://platformio.org/install) (`pio`) | PlatformIO module |
| Docker (+ devcontainer tooling) | devcontainer integration |
| Agent CLIs on `PATH`: `codex`, `claude`, `opencode`, `pi` | agent terminal (only the ones you use) |
| `ipython` | Python REPL in iron.nvim |

LSP servers (clangd, basedpyright, …) and DAP adapters are installed
automatically by Mason on first use — no manual setup required.

## Setup

```sh
git clone git@github.com:usamaimdadsian/nvim-nvchad-custom.git ~/.config/nvim
nvim
```

The first start clones [lazy.nvim](https://github.com/folke/lazy.nvim) and all
plugins automatically. Wait for the install to finish, then restart if needed.

### Machine-specific configuration (`local.lua`)

`lua/config/local.lua` is **gitignored** and holds per-machine settings. Create
it from the example:

```sh
cp lua/config/local.example.lua lua/config/local.lua
```

Currently it is used for Obsidian workspaces (see below). Other machine-specific
values that currently live in `lua/config/options.lua` and may need adjusting
per system:

- `vim.env.PUPPETEER_EXECUTABLE_PATH` — path to the Chromium binary
  (default `/usr/bin/chromium`)

### Optional environment variables

| Variable | Purpose |
| --- | --- |
| `OBSIDIAN_VAULT` | Single-vault Obsidian setup without a `local.lua` file |
| `OBSIDIAN_VAULT_NAME` | Display name for the vault (defaults to `personal`) |

## What's inside

### Base configuration (`lua/config/`)

| File | Purpose |
| --- | --- |
| `lazy.lua` | lazy.nvim bootstrap, LazyVim import, and enabled extras |
| `options.lua` | Global options: system clipboard (`unnamedplus`), cwd-first LSP root spec, `gohtml` → html filetype |
| `keymaps.lua` | Custom keymaps (table below) |
| `project_root.lua` | Project root resolution with git submodule/superproject awareness |
| `local.lua` / `local.example.lua` | Gitignored per-machine settings + template |

**Enabled LazyVim extras:** clangd, cmake, docker, git, go, json, markdown,
php, python, rust, sql, toml, typescript, tex, yaml, java, DAP core, and
nlua.

### Project root detection

`project_root.lua` resolves the "real" working directory for terminals:

1. If the current working directory is itself a git repo inside the LSP
   project root (e.g. a submodule), use the cwd.
2. Otherwise ask git for the superproject working tree (submodule support).
3. Otherwise walk up to the nearest parent git root.

This means `<C-/>` opens a terminal in *your repo*, not the monorepo top level.

### Keymaps

Custom keymaps on top of LazyVim defaults (`<leader>` is Space):

| Key | Mode | Action |
| --- | --- | --- |
| `kj` / `jk` | insert, visual | Exit to normal mode |
| `jk` | terminal | Exit terminal |
| `<leader>bn` | n | New empty buffer |
| `<leader>z` | n | Toggle [Zen mode](https://github.com/folke/zen-mode.nvim) |
| `<C-/>`, `<C-_>`, `<leader>ft` | n, t | Terminal at project root (Snacks) |
| `<leader>e` / `<leader>E` | n | NeoTree at project root / cwd (swapped from LazyVim defaults) |
| `<leader>at` / `<leader>ac` | n | Toggle agent terminal / switch agent |
| `<leader>hb` / `<leader>hu` / `<leader>hm` | n | PlatformIO build / upload / serial monitor |
| `<leader>vdb` / `<leader>vda` / `<leader>vds` / `<leader>vdl` | n | Devcontainer docker build / attach / stop / build logs |
| `<leader>gc` / `<leader>gC` / `<leader>ge` | n | Diffview open / close / compare two commits interactively |
| `<leader>db` / `<leader>dB` | n | Toggle breakpoint / conditional breakpoint (persisted) |
| `<leader>dc` | n | DAP continue (scaffolds `.vscode/launch.json` if missing) |
| `<leader>dU` | n | Reset DAP UI |

**Iron REPL keymaps** (`<space>r…`): `rT` toggle REPL, `rR` restart, `rs` send
motion/visual selection, `rf` send file, `rl` send line, `rq` exit, `rc`
clear, `rz` toggle + focus. In notebooks (jupytext markdown), `<space><CR>`
sends the current `# %%` cell.

**PlatformIO serial monitor keys** (inside the floating terminal): `i` or
`<C-w>j`/`<C-w>p` focus the input line, Enter sends, `<C-l>` cycles line ending
(CRLF/LF/none), `o` jumps back to latest output, `<Esc>` closes, `<C-c>` stops
the monitor.

### AI agent terminal (`lua/plugins/agent.lua`)

Opens your chosen coding-agent CLI in a large floating terminal:

- First invocation asks which agent to use (Codex, Claude Code, OpenCode, Pi);
  the choice is remembered for the session and can be changed with
  `<leader>ac`.
- The terminal is hidden on toggle-off so the agent keeps running; toggling
  back reattaches to the same session.
- Requires the agent's CLI binary on `PATH` (checked before starting).

### PlatformIO module (`lua/plugins/platformio.lua`)

A self-contained workflow for embedded projects:

- Finds the nearest `platformio.ini`, lists its `[env:*]` sections, and asks
  you to pick one when there are several.
- **Build / upload** run in a floating terminal at the project root.
- **Serial monitor** opens two stacked floating windows: live output (auto-
  following) plus a dedicated input line with configurable line endings —
  useful for protocols that expect CRLF.
- After builds, regenerates `compile_commands.json` (`pio run -t compiledb`)
  and restarts clangd so LSP completions stay in sync with the selected env.

### Debugging (`lua/plugins/debugging.lua`)

- [persistent-breakpoints.nvim](https://github.com/Weissle/persistent-breakpoints.nvim)
  saves breakpoints to disk and reloads them on `BufReadPost`.
- Step over/out keymaps (`<leader>do` / `<leader>dO`) alongside LazyVim's DAP
  defaults.
- `<leader>dc` continues the session, or creates a starter `.vscode/launch.json`
  if none exists yet (edit it to match your language's adapter).

### Python & notebooks (`lua/plugins/python.lua`)

- **basedpyright** as the Python LSP with relaxed unknown-type diagnostics.
- **jupytext**: Jupyter notebooks round-trip as markdown, so they get full
  markdown/treesitter treatment in Neovim.
- **iron.nvim**: bottom-docked REPLs for `zsh` and `ipython`, with
  DAP integration and a custom `IronSendCell` command that executes the current
  `# %%` cell (VSCode-style, marker line excluded).

### Obsidian (`lua/plugins/obsidian.lua`)

Integration is **disabled entirely** unless at least one workspace is
configured:

1. `lua/config/local.lua` → `obsidian_workspaces` list (preferred; supports
   multiple vaults). An empty list explicitly disables the plugin.
2. Otherwise the `OBSIDIAN_VAULT` / `OBSIDIAN_VAULT_NAME` environment
   variables.

On save, each note's frontmatter is updated with tags derived from its folder
path (e.g. `Research/Deep Learning/x.md` → tags `Research`, `Deep Learning`).

### Devcontainer (`lua/plugins/init.lua`)

Uses a [patched fork](https://codeberg.org/esensar/nvim-dev-container) of
devcontainer.nvim with a local compatibility shim that substitutes
`${devcontainerId}` in mount paths (hashed from the config file path). Provides
docker build, attach (auto-starts the container if it isn't running), stop, and
build-log commands — see the `<leader>vd*` keymaps.

### Editor additions (`lua/plugins/init.lua`, `editor.lua`)

- [render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim)
  (mermaid code blocks excluded from rendering)
- [snacks.nvim](https://github.com/folke/snacks.nvim) image display and LaTeX
  math rendering
- [neotest](https://github.com/nvim-neotest/neotest) with adapters pulled in by
  the language extras (Python, Go, Pest/PHPUnit)
- [nvim-surround](https://github.com/kylechui/nvim-surround) for surrounding
  text objects
- [hardtime.nvim](https://github.com/m4xshen/hardtime.nvim) to keep insert mode
  escape-free
- [vim-visual-multi](https://github.com/mg979/vim-visual-multi) for multi-cursor
  editing
- [rainbow-delimiters.nvim](https://github.com/hiphish/rainbow-delimiters.nvim)
  (treesitter-gated, so it never runs without a parser)
- lualine extension showing the current project name in the status bar
- Tokyo Night (moon style) as the colorscheme

## Directory layout

```
init.lua                    # bootstraps lua/config/lazy.lua
lua/config/
  lazy.lua                  # lazy.nvim setup + LazyVim extras
  options.lua               # global options & environment
  keymaps.lua               # custom keymaps
  autocmds.lua              # (reserved for custom autocmds)
  project_root.lua          # submodule-aware root detection
  local.lua                 # per-machine settings (gitignored)
  local.example.lua         # template for local.lua
lua/plugins/
  init.lua                  # general plugins, devcontainer, diffview
  agent.lua                 # AI agent CLI floating terminal
  colorsheme.lua            # tokyonight colorscheme
  debugging.lua             # DAP + persistent breakpoints
  editor.lua                # rainbow delimiters, lualine
  obsidian.lua              # Obsidian vault integration
  platformio.lua            # PlatformIO build/upload/monitor
  python.lua                # basedpyright, jupytext, iron REPL
```

## Updating

Plugins update through lazy.nvim's built-in checker (`:Lazy` → *Check for
updates*). The config itself is a git repo — pull as usual. After updating
LazyVim extras, run `:LazyExtras` if you want to add/remove language packs.
