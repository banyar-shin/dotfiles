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

| File | Purpose |
|---|---|
| `.wezterm.lua` | WezTerm — Gruvbox Material, dark/light toggle, fonts |
| `.tmux.conf` | tmux — extended keys, true color, key bindings |
| `.config/kitty/kitty.conf.template` + `generate_kitty_conf.sh` | Kitty config generated from template |
| `.config/kitty/theme.conf` + `themes/` | Catppuccin Macchiato, Gruvbox Material, Rose Pine, Tokyonight |
| `.config/kitty/kittybak.conf`, `kittyold.conf` | Backup variants |
| `.config/ghostty/config` | Ghostty terminal (minimal) |

## Editor

| Path | Purpose |
|---|---|
| `.config/nvim` | nvim config (git submodule) |
| `.config/zed/keymap.json` | Zed key bindings |
| `.config/zed/settings.json` | Zed settings (theme, fonts, AI, etc.) |

## Window management (macOS)

| File | Purpose |
|---|---|
| `.aerospace.toml` | AeroSpace tiling WM — workspace/binding rules |
| `.config/yabai/yabairc` | yabai scripting addition + layout |
| `.config/skhd/skhdrc` | skhd keybindings for yabai |
| `.config/karabiner/karabiner.json` | Karabiner-Elements key remaps |
| `.config/karabiner/automatic_backups/` | Auto-saved snapshots (2024-09 / -10) |

## Git

| File | Purpose |
|---|---|
| `.gitconfig` | Global git config; per-directory `includeIf` for work email |
| `.gitignore` | Global gitignore for the dotfiles bare repo (secrets, history, caches) |
| `.gitmodules` | Submodule pointer (nvim) |
| `.config/git/ignore` | Global gitignore-of-ignores used by `core.excludesfile` |

## Package management

| File | Purpose |
|---|---|
| `.config/Brewfile` | `brew bundle install` — all taps, formulae, casks, mas apps |

## Prompt

| File | Purpose |
|---|---|
| `.config/p10k/mac.p10k.zsh` | powerlevel10k config (zsh prompt; legacy — fish uses oh-my-posh) |

## AI tooling

| Path | Purpose |
|---|---|
| `.claude/settings.json` | Claude Code settings — model, hooks, permissions |
| `.claude/rules/common/*` | Shared coding/git/testing/security rules (loaded into every Claude Code session) |
| `.claude/rules/python/*` | Python-specific rules |
| `.claude/rules/typescript/*` | TypeScript-specific rules |
| `.codex/config.toml` | Codex CLI config |
| `.codex/AGENTS.md` | Codex agent prompt |
| `.codex/rules/default.rules` | Codex rules |
| `.codex/skills/{chronicle,pdf,playwright}/` | Codex skills (incl. PDF + Playwright tools) |
| `.codex/.gitignore` | Codex local-only ignores |

## Tooling — cmux

| File | Purpose |
|---|---|
| `.config/cmux/settings.json` | cmux Settings.app-managed config |
| `.config/cmux/cmux.json` | cmux file-managed overrides (JSONC; takes precedence) |

## Workspace system (`ws` command)

| File | Purpose |
|---|---|
| `.config/workspaces/default.toml` | Default workspace TOML (`[[paths]]`, `[[projects]]`) |
| `.config/workspaces/parse-projects.js` | Shared TOML parser |
| `.config/workspaces/sync-obsidian.js` | Syncs `[[projects]]` to Obsidian vault |

## `gyst` (productivity tooling)

| Path | Purpose |
|---|---|
| `.config/gyst/extract-hook.js` | Hook for `gyst` extraction |
| `.config/gyst/skills/{heartbeat,lookup,reflect,synthesize,update,wrap-up}/SKILL.md` | gyst skill definitions |

## Audio visualizer

| Path | Purpose |
|---|---|
| `.config/cava/config` | cava settings |
| `.config/cava/shaders/*.frag` + `pass_through.vert` | Visualizer shaders (spectrum, spectrogram, etc.) |

## Cosmetics

| Path | Purpose |
|---|---|
| `.config/neofetch/config.conf` + `images/` | Custom neofetch image + config |
| `.config/wallpapers/*` | 19 desktop wallpapers (gruvbox set, etc.) |

## Docs (this repo)

| File | Purpose |
|---|---|
| `.config/dev-setup.md` | Setup/bootstrap reference for this machine |
| `.config/config-map.md` | This file — inventory of tracked configs |

---

## Intentionally NOT tracked

| What | Why |
|---|---|
| **Raycast** (`~/.config/raycast/`) | `config.json` is a bare auth token; `extensions/` is 55MB of per-machine installs. Raycast Pro syncs settings + extensions through its own cloud. On a new machine: install Raycast, sign in, sync runs automatically. |
| **GitHub CLI** (`~/.config/gh/`) | OAuth tokens. Bootstrap: `gh auth login` |
| **GitHub Copilot** (`~/.config/github-copilot/`) | OAuth tokens. Bootstrap: open Copilot in editor, sign in |
| **npm auth** (`~/.npmrc`) | Publish token. Bootstrap: `npm login` |
| **Modal** (`~/.modal.toml`) | API tokens for both personal + work workspaces. Bootstrap: `modal token new --profile=banyar` |
| **Notion API key** (`~/.config/notion/api_key`) | Bootstrap: create new integration at notion.so |
| **X/Twitter** (`~/.xurl`) | OAuth tokens for `xurl` CLI |
| **AWS** (`~/.boto`, `~/.aws/`) | Credentials |
| **Claude state** (`~/.claude.json` + backups) | Per-machine session state, MCP server tokens |
| **Shell history** (`.bash_history`, `.zsh_history`, `.python_history`, etc.) | Personal command history with potentially sensitive arguments |
| **zsh completion caches** (`.zcompdump*`) | Auto-regenerated on first shell start |
| **macOS metadata** (`.DS_Store`, `.localized`) | Spurious diffs |
| **`~/.config/theme-mode`** | Auto-written by WezTerm theme toggle |
| **Orphans** (`~/.zprofil`, `~/.zshrc.pre-oh-my-zsh`, `~/.config/.claude*`, `~/.config/.mcp.json`) | Stale files from past tool installs |
