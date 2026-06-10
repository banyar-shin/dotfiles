#!/usr/bin/env bash
#
# bootstrap.sh — one-command setup for banyar-shin/dotfiles on a fresh macOS box.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/banyar-shin/dotfiles/main/bootstrap.sh | bash
# or, from a clone:
#   git clone https://github.com/banyar-shin/dotfiles.git && ./dotfiles/bootstrap.sh
#
# The repo is managed with the Atlassian bare-repo method: bare git dir at
# ~/.cfg, work-tree = $HOME. This script clones it, checks the dotfiles out
# into $HOME, installs the Brewfile, sets up fish + runtimes, and verifies.
#
# Safe to re-run: every step is idempotent. Credentials/app sign-ins are NOT
# handled here — see ~/.config/dev-setup.md section "Recreate credentials".
#
# Env overrides:
#   DOTFILES_REMOTE   git remote for the dotfiles (default: SSH URL)
#   NODE_VERSION      node version to install via nvm.fish (default: 22.22.2)
#   SKIP_BREW=1       skip `brew bundle`
#   SKIP_RUNTIMES=1   skip node/rust/conda/pnpm
#   SKIP_CHSH=1       don't change the login shell to fish

set -euo pipefail

DOTFILES_REMOTE="${DOTFILES_REMOTE:-git@github.com:banyar-shin/dotfiles.git}"
DOTFILES_REMOTE_HTTPS="https://github.com/banyar-shin/dotfiles.git"
NODE_VERSION="${NODE_VERSION:-22.22.2}"
CFG_DIR="$HOME/.cfg"
BACKUP_DIR="$HOME/.config-backup/$(date +%Y%m%d-%H%M%S)"

# --- logging ----------------------------------------------------------------
if [ -t 1 ]; then
  BOLD=$(printf '\033[1m'); BLUE=$(printf '\033[34m'); GREEN=$(printf '\033[32m')
  YELLOW=$(printf '\033[33m'); RED=$(printf '\033[31m'); RESET=$(printf '\033[0m')
else
  BOLD=""; BLUE=""; GREEN=""; YELLOW=""; RED=""; RESET=""
fi
step() { printf "\n%s==>%s %s%s%s\n" "$BLUE" "$RESET" "$BOLD" "$*" "$RESET"; }
info() { printf "    %s\n" "$*"; }
ok()   { printf "    %s✓%s %s\n" "$GREEN" "$RESET" "$*"; }
warn() { printf "    %s!%s %s\n" "$YELLOW" "$RESET" "$*"; }
die()  { printf "%sERROR:%s %s\n" "$RED" "$RESET" "$*" >&2; exit 1; }

# `config` wrapper for the bare repo
config() { git --git-dir="$CFG_DIR" --work-tree="$HOME" "$@"; }

# --- 0. preflight -----------------------------------------------------------
preflight() {
  step "Preflight"
  [ "$(uname)" = "Darwin" ] || warn "Not macOS — proceeding, but this is tuned for Apple Silicon macOS."

  if ! xcode-select -p >/dev/null 2>&1; then
    info "Installing Xcode Command Line Tools (needed for git/compilers)..."
    xcode-select --install || true
    warn "Finish the CLT install dialog, then re-run this script."
    exit 0
  fi
  ok "Xcode Command Line Tools present"
}

# --- 1. Homebrew ------------------------------------------------------------
install_homebrew() {
  step "Homebrew"
  if [ -x /opt/homebrew/bin/brew ]; then
    BREW_PREFIX=/opt/homebrew
  elif [ -x /usr/local/bin/brew ]; then
    BREW_PREFIX=/usr/local
  else
    info "Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c \
      "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    BREW_PREFIX=/opt/homebrew
    [ -x "$BREW_PREFIX/bin/brew" ] || BREW_PREFIX=/usr/local
  fi
  eval "$("$BREW_PREFIX/bin/brew" shellenv)"
  ok "brew on PATH ($BREW_PREFIX)"
}

# --- 2. dotfiles bare repo --------------------------------------------------
setup_dotfiles() {
  step "Dotfiles (bare repo -> \$HOME)"
  if [ -d "$CFG_DIR" ]; then
    ok "$CFG_DIR already exists — skipping clone"
  else
    info "Cloning $DOTFILES_REMOTE (bare) into $CFG_DIR"
    if ! git clone --bare "$DOTFILES_REMOTE" "$CFG_DIR" 2>/dev/null; then
      warn "SSH clone failed (no key yet?) — falling back to HTTPS"
      git clone --bare "$DOTFILES_REMOTE_HTTPS" "$CFG_DIR"
      config remote set-url origin "$DOTFILES_REMOTE"
      warn "Remote left as SSH for future pushes; add your GitHub SSH key when ready."
    fi
  fi

  # Checkout into $HOME, backing up any pre-existing conflicting files.
  if ! config checkout 2>/dev/null; then
    warn "Checkout conflicts with existing files — backing them up to $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    config checkout 2>&1 | grep -E '^\s+\.' | awk '{print $1}' | while read -r f; do
      mkdir -p "$BACKUP_DIR/$(dirname "$f")"
      mv "$HOME/$f" "$BACKUP_DIR/$f"
    done
    config checkout
  fi

  config config status.showUntrackedFiles no
  info "Initializing submodules (nvim)..."
  config submodule update --init --recursive || \
    warn "Submodule init failed (nvim uses SSH) — run 'config submodule update --init --recursive' after adding your SSH key."
  ok "Dotfiles checked out into \$HOME"
}

# --- 3. Brewfile ------------------------------------------------------------
install_brewfile() {
  step "Brewfile"
  if [ "${SKIP_BREW:-0}" = "1" ]; then warn "SKIP_BREW=1 — skipping"; return; fi
  brew bundle --file="$HOME/.config/Brewfile"
  ok "Brewfile installed"
}

# --- 4. fish + fisher -------------------------------------------------------
setup_fish() {
  step "Fish shell + plugins"
  command -v fish >/dev/null 2>&1 || die "fish not found (Brewfile step skipped?)"

  if ! fish -c "type -q fisher" 2>/dev/null; then
    info "Installing fisher..."
    fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
  fi
  info "Syncing fisher plugins from ~/.config/fish/fish_plugins..."
  fish -c "fisher update"
  ok "fish plugins synced"

  if [ "${SKIP_CHSH:-0}" != "1" ]; then
    local fish_path; fish_path="$(command -v fish)"
    if ! grep -qx "$fish_path" /etc/shells 2>/dev/null; then
      info "Adding $fish_path to /etc/shells (sudo)..."
      echo "$fish_path" | sudo tee -a /etc/shells >/dev/null
    fi
    if [ "${SHELL:-}" != "$fish_path" ]; then
      info "Setting login shell to fish (sudo/password)..."
      chsh -s "$fish_path" || warn "chsh failed — run 'chsh -s $fish_path' manually."
    fi
    ok "Login shell is fish"
  fi
}

# --- 5. runtimes ------------------------------------------------------------
setup_runtimes() {
  step "Runtimes (node / pnpm; uv for Python)"
  if [ "${SKIP_RUNTIMES:-0}" = "1" ]; then warn "SKIP_RUNTIMES=1 — skipping"; return; fi

  info "Node $NODE_VERSION via nvm.fish..."
  fish -c "nvm install $NODE_VERSION; nvm use $NODE_VERSION; set -U nvm_default_version $NODE_VERSION" \
    || warn "nvm install failed — check nvm.fish plugin."

  # pnpm (and yarn, if kept) are installed by the Brewfile — no corepack needed.

  # Python is project-based via uv (installed by the Brewfile). No global env.
  if command -v uv >/dev/null 2>&1; then
    ok "uv present — use 'uv venv' / 'uv sync' per project"
  else
    warn "uv not found — ensure the Brewfile step ran (brew install uv)"
  fi

  # Rust is optional. The dotfiles source ~/.cargo/env if it exists, but we do
  # NOT install rustup here. Set it up by hand when a project needs it:
  #   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  [ -d "$HOME/.cargo" ] && ok "Rust toolchain detected (~/.cargo)"

  ok "Runtimes done"
}

# --- 6. macOS WM note -------------------------------------------------------
wm_note() {
  step "Window manager"
  ok "AeroSpace is the primary WM (cask 'aerospace', reads ~/.aerospace.toml) — launch it once and grant Accessibility."
  info "yabai/skhd configs are tracked as an alternative. To use them instead:"
  info "  yabai --install-service && yabai --start-service"
  info "  skhd  --install-service && skhd  --start-service   (needs Accessibility + SIP exception)"
}

# --- 7. verify --------------------------------------------------------------
verify() {
  step "Verify"
  config status >/dev/null 2>&1 && ok "config status OK" || warn "config status failed"
  if [ "${SKIP_BREW:-0}" != "1" ]; then
    brew bundle check --file="$HOME/.config/Brewfile" >/dev/null 2>&1 \
      && ok "Brewfile satisfied" || warn "Brewfile not fully satisfied (run: brew bundle --file=~/.config/Brewfile)"
  fi
  fish -c "type -q config" 2>/dev/null \
    && ok "fish 'config' function available" || warn "fish functions not loaded yet — open a new fish session"
}

main() {
  printf "%s%s== dotfiles bootstrap ==%s\n" "$BOLD" "$BLUE" "$RESET"
  preflight
  install_homebrew
  setup_dotfiles
  install_brewfile
  setup_fish
  setup_runtimes
  wm_note
  verify
  step "Done"
  ok "Core workflow restored."
  info "Next: recreate credentials & app sign-ins — see the table in ~/.config/dev-setup.md"
  info "Open a fresh terminal (cmux) so fish + the new PATH take effect."
}

main "$@"
