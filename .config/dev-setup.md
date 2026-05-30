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

- **Node** — `~/.local/share/nvm/v22.22.2/` (jorgebucaran/nvm.fish layout). Pinned via `nvm_default_version`.
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
- See [config-map.md](./config-map.md) for the full inventory of tracked files and the curated do-not-track list.

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

- **Claude Code** — primary AI dev tool. `~/.claude/` is machine-local and intentionally not tracked here.
- **Codex** — `~/.codex/` is machine-local and intentionally not tracked here.
- **OpenClaw** — agent workspace at `~/.openclaw/workspace/`, gateway on `:18789`.
- **ruflo** — MCP integration for memory/swarm coordination when configured locally.

## Other

- **zoxide** — `z` for smart cd.
- **fzf** — installed but not init'd from shell (use defaults).
- **`config`** alias works in fish, zsh, bash.
- **`lcj`** — leetcode journal (`~/git-repos/side-projects/lc-notes`, zsh only).

---

## New Machine Bootstrap

Order matters — each step assumes the previous one is done.

### 1. Homebrew + Brewfile

```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"

# After cloning dotfiles (step 2), reinstall everything:
brew bundle --file=~/.config/Brewfile
```

The `Brewfile` is generated via `brew bundle dump --file=~/.config/Brewfile --force`. Regenerate after installing new tools.

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
# Node via nvm.fish
fish -c "nvm install 22.22.2 && nvm use 22.22.2 && set -U nvm_default_version 22.22.2"

# Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Miniconda
brew install --cask miniconda   # or download installer
conda init fish bash zsh

# pnpm
curl -fsSL https://get.pnpm.io/install.sh | sh -
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
| fly.io | `flyctl auth login` |
| Cloudflare | `wrangler login` (if installed) |
| Anthropic API | export `ANTHROPIC_API_KEY` (rotate first if compromised) |
| Claude/Codex | Install/sign in per machine; keep `~/.claude/` and `~/.codex/` out of dotfiles |

### 7. App-managed sync (sign in, not config-tracked)

| App | Setup |
|---|---|
| **Raycast** | Install, sign in to Raycast Pro; settings + extensions sync automatically |
| **1Password** | Install, sign in; vaults sync from cloud |
| **Obsidian** | Install; vault `chrono-brain` syncs via iCloud |
| **Notion (app)** | Install, sign in |
| **Slack** | Sign in to workspaces |
| **Karabiner-Elements** | Installed by Brewfile; load `~/.config/karabiner/karabiner.json` via Preferences → Misc → Open config folder |
| **Yabai/skhd** | After Brewfile: `yabai --install-service && yabai --start-service`, same for `skhd`. Grant Accessibility + SIP exception |
| **AeroSpace** | Installed by Brewfile cask `nikitabobko/tap/aerospace`, reads `~/.aerospace.toml` |

### 8. Verify

```bash
config status                 # should be clean
brew bundle check --file=~/.config/Brewfile
fish -c "type ws && type config && type tmux-personal"
```

### 9. Per-app config notes

- **WezTerm** — Gruvbox Material is set by `~/.wezterm.lua`. `Alt+Shift+D` toggles dark/light. Theme state lives in `~/.config/theme-mode` (NOT tracked — local-only).
- **iTerm2 / Terminal.app** — not used; nothing to migrate.
- **Touch ID for sudo** — re-add to `/etc/pam.d/sudo_local` after a major macOS upgrade.

---

See also: [config-map.md](./config-map.md) for a complete inventory of every tracked file.
