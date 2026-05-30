# ~/.bashrc — bash interactive config, parity with fish (~/.config/fish/)
# macOS ships bash 3.2; keep everything 3.2-compatible.

# Skip rest for non-interactive shells.
case $- in *i*) ;; *) return ;; esac

# ─── PATH (mirrors fish_user_paths + conf.d additions) ──────────────────────
_path_prepend() {
    case ":$PATH:" in
        *":$1:"*) ;;
        *) PATH="$1:$PATH" ;;
    esac
}
_path_prepend "/opt/homebrew/bin"
_path_prepend "/opt/homebrew/sbin"
_path_prepend "/opt/homebrew/opt/openjdk/bin"
_path_prepend "$HOME/.local/bin"
_path_prepend "$HOME/.antigravity/antigravity/bin"

# pnpm (config.fish:11–14)
export PNPM_HOME="$HOME/Library/pnpm"
_path_prepend "$PNPM_HOME"

export PATH

# ─── Editor ─────────────────────────────────────────────────────────────────
export EDITOR="nvim"
export VISUAL="nvim"

# ─── Dotfiles bare repo alias (parity with zsh + fish function) ─────────────
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

# ─── tmux extended-key sequences → Enter at prompt ─────────────────────────
bind '"\e[13;2u": accept-line' 2>/dev/null
bind '"\e[27;2;13~": accept-line' 2>/dev/null

# ─── Cargo / Rust (conf.d/rustup.fish) ──────────────────────────────────────
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# ─── nvm (jorgebucaran/nvm.fish layout, default version pin v22.22.2) ───────
# Fish uses XDG_DATA_HOME/nvm; reuse that install for bash.
NVM_DIR="$HOME/.local/share/nvm"
export NVM_DIR
if [ -d "$NVM_DIR/v22.22.2/bin" ]; then
    _path_prepend "$NVM_DIR/v22.22.2/bin"
    export PATH
fi

# ─── zoxide (conf.d/zoxide.fish) ────────────────────────────────────────────
command -v zoxide >/dev/null && eval "$(zoxide init bash)"

# ─── Prompt: oh-my-posh on bash 4.2+, simple PS1 fallback on macOS bash 3.2 ─
# oh-my-posh's bash init uses `[[ -v VAR ]]` which is 4.2+ syntax.
_omp_supported() {
    [ "${BASH_VERSINFO[0]}" -gt 4 ] && return 0
    [ "${BASH_VERSINFO[0]}" -eq 4 ] && [ "${BASH_VERSINFO[1]}" -ge 2 ] && return 0
    return 1
}

_omp_init() {
    local mode="dark"
    [ -f "$HOME/.config/theme-mode" ] && mode=$(cat "$HOME/.config/theme-mode")
    if [ "$mode" = "light" ]; then
        eval "$(oh-my-posh init bash --config "$HOME/.config/fish/themes/custom-light.omp.json")"
    else
        eval "$(oh-my-posh init bash --config "$HOME/.config/fish/themes/custom.omp.json")"
    fi
}

if command -v oh-my-posh >/dev/null && _omp_supported; then
    _omp_init
else
    # Plain fallback: green user@host, blue cwd, $/# prompt.
    PS1='\[\033[32m\]\u@\h\[\033[0m\]:\[\033[34m\]\w\[\033[0m\]\$ '
fi

theme-reload() {
    if _omp_supported && command -v oh-my-posh >/dev/null; then
        _omp_init
    else
        echo "theme-reload: oh-my-posh requires bash 4.2+ (current ${BASH_VERSION%%(*}); using PS1 fallback" >&2
    fi
}

# ─── conda (lazy, mirrors conf.d/conda-lazy.fish) ───────────────────────────
conda() {
    unset -f conda
    local __conda_setup
    __conda_setup="$("$HOME/miniconda3/bin/conda" shell.bash hook 2>/dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    elif [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
        . "$HOME/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="$HOME/miniconda3/bin:$PATH"
    fi
    conda "$@"
}

# ─── OpenClaw completion (config.fish:25–28) ────────────────────────────────
if command -v openclaw >/dev/null; then
    source <(openclaw completion --shell bash) 2>/dev/null
fi

# ─── tmux session helpers (config.fish:30–82) ───────────────────────────────
tmux-ego() {
    if tmux has-session -t ego 2>/dev/null; then
        if [ -n "$TMUX" ]; then tmux switch-client -t ego
        else tmux attach -t ego; fi
    else
        tmux new -s ego -c ~/git-repos/work/_ego
    fi
}

tmux-personal() {
    if tmux has-session -t personal 2>/dev/null; then
        if [ -n "$TMUX" ]; then tmux switch-client -t personal
        else tmux attach -t personal; fi
    else
        tmux new -s personal
    fi
}

tmux-nexus() { ~/.local/bin/tmux-nexus "$@"; }

# ─── nexus helpers (config.fish:58–70) ──────────────────────────────────────
nexus() {
    cd /Users/banyar/git-repos/nexus/hermes-agent || return
    HERMES_HOME=/Users/banyar/git-repos/nexus-instance ./.venv/bin/hermes "$@"
}
nexus-browser() { ~/.local/bin/nexus-browser "$@"; }
nexus-claude()  { ~/.local/bin/nexus-claude  "$@"; }

# ─── git wrapper (functions/git.fish): post fetch/pull/push timeline hook ───
git() {
    command git "$@"
    local exit_code=$?
    if [ $exit_code -eq 0 ]; then
        case "$1" in
            fetch|pull|push)
                local repo_root
                repo_root=$(command git rev-parse --show-toplevel 2>/dev/null)
                if [ -n "$repo_root" ] && [ -f "$repo_root/scripts/update-timeline.js" ]; then
                    (node "$repo_root/scripts/update-timeline.js" >/dev/null 2>&1 &)
                fi
                ;;
        esac
    fi
    return $exit_code
}

# ─── ws workspace manager (bash port of functions/ws.fish) ──────────────────
ws() {
    local ws_dir="$HOME/.config/workspaces"
    local cmd="${1:-open}"
    case "$cmd" in
        edit)
            local name="${2:-default}"
            local file="$ws_dir/$name.toml"
            [[ -f "$file" ]] || { echo "Workspace '$name' not found. Use: ws new $name"; return 1; }
            zed "$file"
            ;;
        list|ls)
            echo "Workspaces:"
            local f
            for f in "$ws_dir"/*.toml; do
                local name count
                name=$(basename "$f" .toml)
                count=$(grep -c '^path = ' "$f" 2>/dev/null || echo 0)
                echo "  $name ($count paths)"
            done
            ;;
        new)
            local name="$2"
            [[ -n "$name" ]] || { echo "Usage: ws new <name>"; return 1; }
            local file="$ws_dir/$name.toml"
            [[ ! -f "$file" ]] || { echo "Workspace '$name' already exists. Use: ws edit $name"; return 1; }
            cat > "$file" <<EOF
# Zed Workspace: $name

[workspace]
name = "$name"

# [[paths]]
# path = "~/some/project"
# label = "my project"
EOF
            echo "Created workspace '$name'. Use: ws edit $name"
            ;;
        add)
            local target="$2"
            local name="${3:-default}"
            [[ -n "$target" ]] || { echo "Usage: ws add <path> [workspace]"; return 1; }
            local resolved label
            resolved=$(realpath "$target" 2>/dev/null || echo "$target")
            label=$(basename "$resolved")
            cat >> "$ws_dir/$name.toml" <<EOF

[[paths]]
path = "$resolved"
label = "$label"
EOF
            echo "Added '$resolved' to workspace '$name'"
            ;;
        rm|remove)
            local target="$2"
            local name="${3:-default}"
            [[ -n "$target" ]] || { echo "Usage: ws rm <path> [workspace]"; return 1; }
            local file="$ws_dir/$name.toml"
            local resolved tmp
            resolved=$(realpath "$target" 2>/dev/null || echo "$target")
            tmp=$(mktemp)
            awk -v target="$resolved" '
                /^\[\[paths\]\]/ { block=""; capture=1 }
                capture { block=block $0 "\n"; if (/^path = / && index($0,target)) { skip=1 }; if (/^$/ || (/^\[/ && !/^\[\[paths\]\]/)) { capture=0; if (!skip) printf "%s",block; skip=0; next }; next }
                { print }
            ' "$file" > "$tmp"
            mv "$tmp" "$file"
            echo "Removed '$resolved' from workspace '$name'"
            ;;
        sync)
            node ~/.config/workspaces/sync-obsidian.js
            ;;
        info)
            node ~/.config/workspaces/parse-projects.js --info "$2"
            ;;
        open|*)
            local name="$cmd"
            [[ "$cmd" = "open" ]] && name="${2:-default}"
            local file="$ws_dir/$name.toml"
            [[ -f "$file" ]] || { echo "Workspace '$name' not found."; ws list; return 1; }
            local dirs=()
            local p expanded
            while IFS= read -r p; do
                expanded="${p/#\~/$HOME}"
                if [[ -d "$expanded" ]]; then
                    dirs+=("$expanded")
                else
                    echo "Warning: '$expanded' not found, skipping"
                fi
            done < <(grep '^path = ' "$file" | sed 's/^path = "//;s/"$//')
            [[ ${#dirs[@]} -gt 0 ]] || { echo "No valid paths in workspace '$name'. Use: ws edit $name"; return 1; }
            echo "Opening workspace '$name' with ${#dirs[@]} projects..."
            zed "${dirs[@]}"
            ;;
    esac
}
