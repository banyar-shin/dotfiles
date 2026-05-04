# # Old zshrc to switch between OSes
# # What OS are we running?
# if [[ $(uname) == "Darwin" ]]; then
#     source ~/.config/zsh/mac.zsh
#
# elif command -v pacman > /dev/null; then
#     source ~/.config/zsh/arch.zsh
#
# elif command -v freebsd-version > /dev/null; then
#     source "$ZSH_CUSTOM"/os/freebsd.zsh
#
# else
#     echo 'Unknown OS!'
# fi

########################################################################################

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

plugins=(git)

source $ZSH/oh-my-zsh.sh

# Let tmux extended-key sequences behave like Enter at the shell prompt.
bindkey '\e[13;2u' accept-line
bindkey '\e[27;2;13~' accept-line

alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export EDITOR="nvim"
export VISUAL="nvim"

eval "$(zoxide init zsh)"

export LCJ_PATH="$HOME/git-repos/side-projects/lc-notes"
alias lcj="$LCJ_PATH/lc-journal.sh"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$("$HOME/miniconda3/bin/conda" "shell.zsh" "hook" 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
        . "$HOME/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="$HOME/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


# OpenClaw Completion
source <(openclaw completion --shell zsh)

# Workspace manager
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
      for f in "$ws_dir"/*.toml; do
        local name=$(basename "$f" .toml)
        local count=$(grep -c '^path = ' "$f" 2>/dev/null || echo 0)
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
      local resolved=$(realpath "$target" 2>/dev/null || echo "$target")
      local label=$(basename "$resolved")
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
      local resolved=$(realpath "$target" 2>/dev/null || echo "$target")
      local file="$ws_dir/$name.toml"
      local tmp=$(mktemp)
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
      while IFS= read -r p; do
        local expanded="${p/#\~/$HOME}"
        [[ -d "$expanded" ]] && dirs+=("$expanded") || echo "Warning: '$expanded' not found, skipping"
      done < <(grep '^path = ' "$file" | sed 's/^path = "//;s/"$//')
      [[ ${#dirs[@]} -gt 0 ]] || { echo "No valid paths in workspace '$name'. Use: ws edit $name"; return 1; }
      echo "Opening workspace '$name' with ${#dirs[@]} projects..."
      zed "${dirs[@]}"
      ;;
  esac
}
