# Dev Setup

macOS (Apple Silicon). Notes on the moving parts.

## Shell

- **fish** (`/opt/homebrew/bin/fish`) — primary interactive shell. Config at `~/.config/fish/`.
- **zsh** — fallback; `~/.zshrc` mirrors fish for tools that assume bash/zsh.
- **bash** — `~/.bashrc` sourced by `~/.bash_profile`. macOS bash is 3.2; uses a plain PS1 fallback (oh-my-posh needs 4.2+).
- **fish plugins** (fisher): `jorgebucaran/nvm.fish`, `jorgebucaran/autopair.fish`.
- Conda is **lazy-loaded** in fish/bash (first `conda` call sources the hook).

## Terminal & Editor

- **WezTerm** — Gruvbox Material. `Alt+Shift+D` toggles dark/light (writes `~/.config/theme-mode`, `theme-reload` re-inits oh-my-posh).
- **Zed** — primary GUI editor; opened via `ws` (workspace manager).
- **nvim** — `$EDITOR`/`$VISUAL`; terminal editing.
- **Prompt:** oh-my-posh, themes at `~/.config/fish/themes/custom{,-light}.omp.json`.

## Runtimes

- **Node** — `~/.local/share/nvm/v22.22.0/` (jorgebucaran/nvm.fish layout). Pinned via `nvm_default_version`.
- **Python** — miniconda3 at `~/miniconda3/`. Per-directory env auto-switch via `env-switch.fish` (currently disabled — slow conda subprocess on shell start).
- **Rust** — `~/.cargo/`, sourced from `~/.cargo/env`.
- **pnpm** — `~/Library/pnpm` (Node package manager of choice).
- **JDK** — `/opt/homebrew/opt/openjdk/bin`.

## Dotfiles (bare git repo)

Atlassian bare-repo method — repo at `~/.cfg/`, work-tree is `$HOME`.

```fish
config status        # see what changed
config add <file>    # stage a dotfile
config commit -m ".."
config push
```

- Remote: `git@github.com:banyar-shin/dotfiles.git`
- `status.showUntrackedFiles=no` — new files don't show in `status` until added explicitly.

### Git email routing

Global email is `banyar.minshin@gmail.com`. Repos under `~/git-repos/ego/` switch to `banyar@ego.live` via `includeIf` in `.gitconfig`.

## Workspace System (`ws`)

Source of truth: `~/.config/workspaces/*.toml`. Defined in fish, zsh, and bash (parity).

| Command | Action |
|---|---|
| `ws` | Open default workspace in Zed |
| `ws list` / `ls` | List workspaces |
| `ws edit [name]` | Edit a workspace TOML |
| `ws new <name>` | Create a workspace |
| `ws add <path>` | Add a path |
| `ws rm <path>` | Remove a path |
| `ws sync` | Sync `[[projects]]` → Obsidian |
| `ws info` | Show project details |

Scripts: `~/.config/workspaces/parse-projects.js`, `sync-obsidian.js` (only touches notes with `source: workspace-toml` frontmatter — hand-written notes are safe).

## Obsidian Vault — `chrono-brain`

`~/Library/Mobile Documents/iCloud~md~obsidian/Documents/chrono-brain/`

- `banyar/` — user workspace (tasks, inbox)
- `chrono/` — AI workspace (daily-logs, session-logs, background-activities)
- `second-brain/` — knowledge base (entities, projects, concepts, lessons)

Conventions: full-path wikilinks, YAML frontmatter required in `second-brain/`, folder notes pattern `{folder}/{folder}.md`. See `VAULT-RULES.md` in the vault.

## Project Layout

```
~/git-repos/
├── ego/              # EgoAI work (banyar@ego.live)
├── immvrse/          # IMMVRSE-TECH
├── personal/         # banyar-shin + _school/
├── oss/              # third-party clones
└── local-sandboxing/ # no-git experiments
```

## tmux Session Helpers

`tmux-ego`, `tmux-personal`, `tmux-immvrse`, `tmux-nexus` — attach if exists, else create with the right cwd. Switches client when already inside tmux.

## AI Tooling

- **Claude Code** — primary AI dev tool. Settings at `~/.claude/settings.json`; auto-memory at `~/.claude/projects/-Users-banyar-ego/memory/`; rules at `~/.claude/rules/`.
- **OpenClaw** — agent workspace at `~/.openclaw/workspace/`, gateway on `:18789`.
- **ruflo** — MCP integration for memory/swarm coordination (see `~/.claude/CLAUDE.md`).

## Other

- **zoxide** — `z` for smart cd.
- **fzf** — installed but not init'd from shell (use defaults).
- **`config`** alias works in fish, zsh, bash.
- **`lcj`** — leetcode journal (`~/git-repos/side-projects/lc-notes`, zsh only).
