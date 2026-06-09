# Config Map

Inventory of every tracked file in this dotfiles repo, grouped by area. The bare-repo work-tree is `$HOME`, so paths shown are relative to `~`.

For setup instructions (install order, bootstrap), see [dev-setup.md](./dev-setup.md).
For exclusion rules (what's intentionally NOT tracked and why), see [`~/.gitignore`](../.gitignore).

---

## Shells

| File | Purpose |
|---|---|
| `.zshrc` | zsh interactive config — aliases, completions, prompt, `ws` function |
| `.zshenv` | sources `~/.cargo/env` so cargo is on PATH in non-interactive shells |
| `.zprofile` | runs `brew shellenv` on login — first-line PATH setup |
| `.bashrc` | bash interactive config, mirrors fish setup for parity |
| `.bash_profile` | sources `.bashrc` on login shells |
| `.profile` | POSIX fallback; sources cargo env |

## Fish (primary shell)

`~/.config/fish/`

| Path | Purpose |
|---|---|
| `config.fish` + `config.fish.backup` | Fish entry point |
| `fish_plugins` | Fisher plugin manifest |
| `fish_variables` | Universal vars (theme, default node version) |
| `conf.d/` | Auto-sourced conf snippets: `conda-lazy`, `fzf`, `neofetch`, `nvm`, `oh-my-posh`, `rustup`, `zoxide` |
| `completions/` | Completion files: `fisher`, `nvm`, `rustup` |
| `functions/` | `config`, `env-switch`, `fisher`, `nvm` (+ helpers), `theme-reload`, `ws` |
| `themes/` | oh-my-posh themes: `custom`, `custom-light`, `blueish`, `gruvbox` |
| `.fisher/` | Vendored Fisher plugins (autopair, nvm) |

## Terminals

**Primary: cmux** (see "Tooling — cmux" below). WezTerm/kitty/ghostty are tracked alternatives, kept in case of a switch-back but not the daily driver.

| File | Purpose |
|---|---|
| `.config/cmux/cmux.json` | **cmux — primary terminal/workspace app** (file-managed overrides) |
| `.tmux.conf` | tmux — extended keys, true color, key bindings |
| `.wezterm.lua` | WezTerm (alternative) — Gruvbox Material, dark/light toggle, fonts |
| `.config/kitty/kitty.conf.template` + `generate_kitty_conf.sh` | Kitty (alternative) config generated from template |
| `.config/kitty/theme.conf` + `themes/` | Catppuccin Macchiato, Gruvbox Material, Rose Pine, Tokyonight |
| `.config/kitty/kittybak.conf`, `kittyold.conf` | Backup variants |
| `.config/ghostty/config` | Ghostty (alternative) terminal (minimal) |

## Editor

| Path | Purpose |
|---|---|
| `.config/nvim` | nvim config (git submodule) |
| `.config/zed/keymap.json` | Zed key bindings |
| `.config/zed/settings.json` | Zed settings (theme, fonts, AI, etc.) |

## Window management (macOS)

**Primary: AeroSpace.** yabai + skhd are tracked alternatives (kept in case of a switch-back), not the daily driver.

| File | Purpose |
|---|---|
| `.aerospace.toml` | **AeroSpace tiling WM (primary)** — workspace/binding rules |
| `.config/yabai/yabairc` | yabai (alternative) scripting addition + layout |
| `.config/skhd/skhdrc` | skhd (alternative) keybindings for yabai |
| `.config/karabiner/karabiner.json` | Karabiner-Elements key remaps |
| `.config/karabiner/automatic_backups/` | Auto-saved snapshots (2024-09 / -10) |

## Git

| File | Purpose |
|---|---|
| `.gitconfig` | Global git config; includes work identity for `_ego` checkouts |
| `.gitignore` | Global gitignore for the dotfiles bare repo (secrets, history, caches) |
| `.gitmodules` | Submodule pointer (nvim) |
| `.config/git/ignore` | Global gitignore-of-ignores used by `core.excludesfile` |
| `.config/git/ego.gitconfig` | Work git identity included for `~/git-repos/work/_ego/` |

## Package management

| File | Purpose |
|---|---|
| `.config/Brewfile` | `brew bundle` — **hand-curated, minimal** set of taps/formulae/casks/vscode/cargo/uv/npm. Edit by hand; don't `brew bundle dump` over it. |

## Prompt

| File | Purpose |
|---|---|
| `.config/p10k/mac.p10k.zsh` | powerlevel10k config — used for zsh sessions; fish uses oh-my-posh |

## Tooling — cmux

| File | Purpose |
|---|---|
| `.config/cmux/settings.json` | cmux Settings.app-managed config |
| `.config/cmux/cmux.json` | cmux file-managed overrides (JSONC; takes precedence) |

## Workspace system (`ws` command) — experimental, not core

Tracked but no longer part of the core workflow (see dev-setup.md). Safe to ignore or remove.

| File | Purpose |
|---|---|
| `.config/workspaces/default.toml` | Default workspace TOML (`[[paths]]`, `[[projects]]`) |
| `.config/workspaces/parse-projects.js` | Shared TOML parser |
| `.config/workspaces/sync-obsidian.js` | Syncs `[[projects]]` to Obsidian vault |

## Audio visualizer

| Path | Purpose |
|---|---|
| `.config/cava/config` | cava settings |
| `.config/cava/shaders/*.frag` + `pass_through.vert` | Visualizer shaders (spectrum, spectrogram, etc.) |

## Cosmetics

| Path | Purpose |
|---|---|
| `.config/neofetch/config.conf` + `images/` | Custom neofetch image + config |
| `.config/wallpapers/*` | 18 desktop wallpapers (gruvbox set, etc.) |

## Docs (this repo)

| File | Purpose |
|---|---|
| `bootstrap.sh` | **One-command new-machine setup** (Homebrew → bare-repo checkout → Brewfile → fish + plugins → runtimes → verify). Idempotent. |
| `.config/dev-setup.md` | Setup/bootstrap reference for this machine |
| `.config/config-map.md` | This file — inventory of tracked configs |

---

## Intentionally NOT tracked

| What | Why |
|---|---|
| **Raycast** config (`~/.config/raycast/`) | Raycast itself is a **core tool, installed via the Brewfile** (`cask "raycast"`). Only its local config stays out of git: `config.json` is a bare auth token and `extensions/` is 55MB of per-machine installs. Raycast Pro syncs settings + extensions through its own cloud — on a new machine, sign in and sync runs automatically. |
| **GitHub CLI** (`~/.config/gh/`) | OAuth tokens. Bootstrap: `gh auth login` |
| **GitHub Copilot** (`~/.config/github-copilot/`) | OAuth tokens. Bootstrap: open Copilot in editor, sign in |
| **npm auth** (`~/.npmrc`) | Publish token. Bootstrap: `npm login` |
| **Modal** (`~/.modal.toml`) | API tokens for both personal + work workspaces. Bootstrap: `modal token new --profile=banyar` |
| **Notion API key** (`~/.config/notion/api_key`) | Bootstrap: create new integration at notion.so |
| **X/Twitter** (`~/.xurl`) | OAuth tokens for `xurl` CLI |
| **AWS** (`~/.boto`, `~/.aws/`) | Credentials |
| **Claude Code config** (`~/.claude/`) | Machine-local settings, rules, sessions, hooks, MCP config, and auth-adjacent state |
| **Codex config** (`~/.codex/`) | Machine-local model/plugin/project trust settings, skills, sessions, and runtime paths |
| **Claude state** (`~/.claude.json` + backups) | Per-machine session state, MCP server tokens |
| **Shell history** (`.bash_history`, `.zsh_history`, `.python_history`, etc.) | Personal command history with potentially sensitive arguments |
| **zsh completion caches** (`.zcompdump*`) | Auto-regenerated on first shell start |
| **macOS metadata** (`.DS_Store`, `.localized`) | Spurious diffs |
| **`~/.config/theme-mode`** | Auto-written by WezTerm theme toggle |
| **Orphans** (`~/.zprofil`, `~/.zshrc.pre-oh-my-zsh`, `~/.config/.claude*`, `~/.config/.mcp.json`) | Stale files from past tool installs |
