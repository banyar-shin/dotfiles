# Environment

- **Shell**: fish (`/opt/homebrew/bin/fish`), zsh available as fallback
- **Terminal**: WezTerm (Gruvbox Material, Alt+Shift+D toggles dark/light)
- **Editor**: Zed (opened via `ws` command), nvim for terminal editing
- **Node**: v22.22.0 via nvm at `~/.local/share/nvm/`

## Dotfiles (bare git repo)

Managed via the Atlassian bare-repo method. The repo lives at `~/.cfg/` with `$HOME` as the work-tree.

```bash
# Use the `config` alias (defined in fish and zsh)
config status
config add .wezterm.lua
config commit -m "update wezterm"
config push
```

Remote: `git@github.com:banyar-shin/dotfiles.git`

**Git email routing**: Global email is `banyar.minshin@gmail.com`. Repos under `~/git-repos/ego/` use `banyar@ego.live` via `includeIf` in `.gitconfig`.

## Workspace System

Source of truth: `~/.config/workspaces/*.toml`

### Commands (`ws`)

Defined in both `~/.config/fish/functions/ws.fish` and `~/.zshrc`:

| Command | Action |
|---|---|
| `ws` | Open default workspace in Zed |
| `ws edit` | Edit workspace TOML |
| `ws list` | List all workspaces |
| `ws sync` | Sync projects to Obsidian vault |
| `ws info` | Show project details |
| `ws add <path>` | Add a path |
| `ws rm <path>` | Remove a path |
| `ws new <name>` | Create a new workspace |

### TOML Schema

```toml
# Paths drive Zed (ws open)
[[paths]]
path = "~/some/dir"
label = "display name"

# Projects drive Obsidian sync (ws sync) and living docs
[[projects]]
name = "Project Name"
description = "What it does"
type = "repo"           # repo | life | infra | learning
status = "active"       # active | paused | completed | idea
tags = ["org", "topic"]
path = "~/some/dir"     # optional, links to [[paths]]
started = "2026-03-01"
```

### Scripts (`~/.config/workspaces/`)

| Script | Purpose |
|---|---|
| `parse-projects.js` | TOML parser, shared lib (`require.main` guarded) |
| `sync-obsidian.js` | Syncs `[[projects]]` to Obsidian `second-brain/projects/` |

**Sync safety**: Only creates/updates notes with `source: workspace-toml` in frontmatter. Hand-written notes are never overwritten.

## Obsidian Vault (chrono-brain)

Location: `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/chrono-brain/`

Three-area structure:
- `banyar/` — user workspace (tasks, inbox)
- `chrono/` — AI workspace (daily-logs, session-logs, background-activities)
- `second-brain/` — knowledge base (entities, projects, concepts, lessons)

**Vault rules** (see `VAULT-RULES.md` in vault):
- Always use full-path wikilinks: `[[second-brain/projects/Chat App|Chat App]]`
- YAML frontmatter required on `second-brain/` notes
- Folder notes pattern: `{folder}/{folder}.md`
- Tasks use Obsidian Tasks emoji format (not text format)

## OpenClaw

Agent workspace at `~/.openclaw/workspace/`. Config at `~/.openclaw/openclaw.json`. Gateway runs locally on port 18789.

## Project Directory Layout

```
~/git-repos/
├── ego/              # EgoAI work (uses banyar@ego.live)
├── immvrse/          # IMMVRSE-TECH
├── personal/         # banyar-shin repos + _school/
├── oss/              # third-party clones
└── local-sandboxing/ # no-git experiments
```
