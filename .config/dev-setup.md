# Dev Setup

macOS (Apple Silicon). Notes on the moving parts.

## Shell

- **fish** (`/opt/homebrew/bin/fish`) — primary interactive shell. Config at `~/.config/fish/`.
- **zsh** — fallback; `~/.zshrc` mirrors fish for tools that assume bash/zsh.
- **bash** — `~/.bashrc` sourced by `~/.bash_profile`. macOS bash is 3.2; uses a plain PS1 fallback (oh-my-posh needs 4.2+).
- **fish plugins** (fisher): `jorgebucaran/nvm.fish`, `jorgebucaran/autopair.fish`.
- Conda (legacy) is **lazy-loaded** in fish/bash if installed — Python is now uv project-based; the conda hook only matters on machines that still have miniconda.

## Terminal & Editor

- **cmux** (manaflow-ai) — **primary terminal/workspace app.** Config at `~/.config/cmux/cmux.json` (JSONC; file-managed overrides take precedence over the in-app Settings). Pane focus bound to `opt+h/j/k/l`.
- **WezTerm / kitty / ghostty** — *alternative terminals, configs still tracked but not primary and **not installed by the Brewfile**.* Kept in case I switch back; `brew install --cask wezterm ghostty` (or kitty) if needed. WezTerm: Gruvbox Material, `Alt+Shift+D` toggles dark/light (writes `~/.config/theme-mode`, `theme-reload` re-inits oh-my-posh). kitty config is generated from a template via `generate_kitty_conf.sh`.
- **Zed** — primary GUI editor.
- **nvim** — `$EDITOR`/`$VISUAL`; terminal editing.
- **Prompt:** oh-my-posh (fish), themes at `~/.config/fish/themes/custom{,-light}.omp.json`. powerlevel10k (`~/.config/p10k/`) kept for zsh sessions.

## Runtimes

- **Node** (core) — `~/.local/share/nvm/v22.22.2/` (jorgebucaran/nvm.fish layout). Pinned via `nvm_default_version`.
- **pnpm** (core) — installed via the Brewfile (Node package manager of choice). corepack ships with node if you ever need yarn.
- **Python** (core) — **project-based via `uv`** (`uv venv` / `uv sync` per project). No global interpreter to manage. _Conda is no longer part of the core setup;_ `conda-lazy.fish` remains as legacy config in case a machine still has miniconda.
- **Rust** (optional) — not installed by bootstrap. The shell sources `~/.cargo/env` **if present**, so install rustup by hand only when a project needs it: `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`.
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
- See [config-map.md](./config-map.md) for the full inventory of tracked files and the curated do-not-track list.

### Git email routing

Global email is `banyar.minshin@gmail.com`. Repos under `~/git-repos/work/_ego/` switch to `banyar@ego.live` via `.gitconfig` including `~/.config/git/ego.gitconfig`.

## Workspace System (`ws`) — experimental, not core

> An experiment I built and no longer rely on. The fish/zsh/bash functions and
> `~/.config/workspaces/` files are still tracked, but `ws` is **not part of the
> core workflow** and the bootstrap script does not depend on it. Documented
> here for reference; safe to ignore (or delete) on a new machine.

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
├── work/_ego/                     # EgoAI work (banyar@ego.live)
├── personal/                      # personal projects and experiments
├── career/                        # career/interview projects
├── nexus/                         # Hermes/Nexus source checkout
├── nexus-instance/                # mutable local Hermes/Nexus runtime state
└── agent-first-workspace-starter/ # workspace starter/reference project
```

## tmux Session Helpers

`tmux-ego`, `tmux-personal`, `tmux-nexus` — attach if exists, else create with the right cwd. Switches client when already inside tmux.

## AI Tooling

- **Claude Code** — primary AI dev tool. `~/.claude/` is machine-local and intentionally not tracked here.
- **Codex** — `~/.codex/` is machine-local and intentionally not tracked here.
- **OpenClaw** — agent workspace at `~/.openclaw/workspace/`, gateway on `:18789`.

## Other

- **zoxide** (core) — smart `cd`: `z <dir>` jumps by frecency, `zi` opens an interactive fzf picker. Installed via Brewfile; initialized in fish (`conf.d/zoxide.fish`), zsh, and bash.
- **fzf** (core) — fuzzy finder; a dependency of zoxide's `zi`. Installed via Brewfile, not init'd as a standalone shell binding (uses defaults).
- **`config`** alias works in fish, zsh, bash.
- **`lcj`** — leetcode journal (`~/git-repos/side-projects/lc-notes`, zsh only).

---

## New Machine Bootstrap

### The one-command path (preferred)

Everything below (Homebrew → bare-repo checkout → Brewfile → fish + plugins →
runtimes → verify) is automated by **`~/bootstrap.sh`** (tracked at the repo
root). On a fresh machine:

```bash
curl -fsSL https://raw.githubusercontent.com/banyar-shin/dotfiles/main/bootstrap.sh | bash
```

The script is idempotent (safe to re-run) and honors `SKIP_BREW`,
`SKIP_RUNTIMES`, `SKIP_CHSH`, `DOTFILES_REMOTE`, and `NODE_VERSION` env
overrides. It does **not** handle credentials/app sign-ins — do step 6 & 7
below by hand afterward.

The manual steps below are the reference for what the script does (and for
debugging when a step fails).

### Manual steps (reference)

Order matters — each step assumes the previous one is done.

### 1. Homebrew + Brewfile

```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"

# After cloning dotfiles (step 2), reinstall everything:
brew bundle --file=~/.config/Brewfile
```

The `Brewfile` is a **hand-curated, minimal** install set — not a raw `brew
bundle dump`. Running `dump` re-adds every one-off experimental tool, so edit
the file by hand to keep it deliberate. Add new keepers as you adopt them.

### 2. Dotfiles bare repo

```bash
git clone --bare git@github.com:banyar-shin/dotfiles.git $HOME/.cfg
alias config='git --git-dir=$HOME/.cfg --work-tree=$HOME'
config checkout
config config status.showUntrackedFiles no
config submodule update --init --recursive   # nvim
```

If `config checkout` reports conflicts with macOS defaults (`.zshrc`, `.bash_profile`), move them aside and rerun:

```bash
mkdir -p ~/.config-backup
config checkout 2>&1 | egrep "\s+\." | awk '{print $1}' | xargs -I{} mv {} ~/.config-backup/
config checkout
```

### 3. Shells (fish + fisher)

```bash
fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
fish -c "fisher update"   # reads ~/.config/fish/fish_plugins
chsh -s /opt/homebrew/bin/fish
```

### 4. Runtimes

```bash
# Node via nvm.fish (core)
fish -c "nvm install 22.22.2 && nvm use 22.22.2 && set -U nvm_default_version 22.22.2"

# pnpm comes from the Brewfile (core). corepack ships with node for yarn.

# Python: project-based via uv (installed by the Brewfile) — nothing global.
#   uv venv && uv sync       # per project

# Rust (optional, only if a project needs it):
#   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

### 5. Editors

- **Zed** — installed by Brewfile; settings auto-load from `~/.config/zed/`
- **nvim** — submodule checkout above; first launch installs plugins via lazy.nvim
- **Cursor** — install separately if needed

### 6. Recreate credentials & app sign-ins

Nothing here is tracked in the dotfiles repo. Run these on the new machine:

| Tool | Command / Action |
|---|---|
| GitHub CLI | `gh auth login` |
| GitHub Copilot | Sign in via editor |
| SSH key for GitHub | Copy personal `~/.ssh/id_ed25519` from external drive; `ssh-add --apple-use-keychain ~/.ssh/id_ed25519` |
| npm | `npm login` (regenerate publish token if needed) |
| Modal | `modal token new --profile=banyar` (use personal account only) |
| Notion | Create new integration at notion.so/my-integrations; write key to `~/.config/notion/api_key` |
| AWS | `aws configure` (if needed) |
| fly.io | `brew install flyctl` then `flyctl auth login` (no longer in core Brewfile) |
| Cloudflare | `wrangler login` (if installed) |
| Anthropic API | export `ANTHROPIC_API_KEY` (rotate first if compromised) |
| Claude/Codex | Install/sign in per machine; keep `~/.claude/` and `~/.codex/` out of dotfiles |

### 7. App-managed sync (sign in, not config-tracked)

| App | Setup |
|---|---|
| **Raycast** (core) | Installed by the Brewfile (`cask "raycast"`). Sign in to Raycast Pro — settings + extensions then sync automatically via the cloud (the local `~/.config/raycast/` is an auth token + ~55MB of per-machine extensions, so it stays out of git). |
| **1Password** | Install, sign in; vaults sync from cloud |
| **Obsidian** | Install; vault `chrono-brain` syncs via iCloud |
| **Notion (app)** | Install, sign in |
| **Slack** | Sign in to workspaces |
| **Karabiner-Elements** | Installed by Brewfile; load `~/.config/karabiner/karabiner.json` via Preferences → Misc → Open config folder |
| **AeroSpace** (primary WM) | Installed by Brewfile cask `nikitabobko/tap/aerospace`, reads `~/.aerospace.toml`. Launch once, grant Accessibility. |
| **Yabai/skhd** (alternative) | Configs tracked but not the daily driver. Only if switching off AeroSpace: `yabai --install-service && yabai --start-service`, same for `skhd`. Grant Accessibility + SIP exception. |

### 8. Verify

```bash
config status                 # should be clean
brew bundle check --file=~/.config/Brewfile
fish -c "type config && type tmux-personal"
```

### 9. Per-app config notes

- **cmux** (primary terminal) — settings live in the app; `~/.config/cmux/cmux.json` holds file-managed overrides (pane focus `opt+h/j/k/l`). On first launch cmux writes a `settings.json` template (not tracked — app/machine-local).
- **WezTerm** (alternative, not auto-installed) — `brew install --cask wezterm` if needed. Gruvbox Material set by `~/.wezterm.lua`. `Alt+Shift+D` toggles dark/light. Theme state lives in `~/.config/theme-mode` (NOT tracked — local-only).
- **iTerm2 / Terminal.app** — not used; nothing to migrate.
- **Touch ID for sudo** — re-add to `/etc/pam.d/sudo_local` after a major macOS upgrade.

---

See also: [config-map.md](./config-map.md) for a complete inventory of every tracked file.
