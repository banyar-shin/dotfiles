# ~/.config/fish/conf.d runs first

# https://fishshell.com/docs/current/tutorial.html
# https://github.com/jorgebucaran/fish-shell-cookbook
# https://github.com/fish-shell/fish-shell/blob/master/share/config.fish
# https://github.com/fish-shell/fish-shell/blob/da32b6c172dcfe54c9dc4f19e46f35680fc8a91a/share/config.fish#L257-L269

# conda is lazy-loaded via ~/.config/fish/conf.d/conda-lazy.fish

# pnpm
set -gx PNPM_HOME "$HOME/Library/pnpm"
if not string match -q -- $PNPM_HOME $PATH
    set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

# source ~/.config/fish/functions/env-switch.fish  # disabled — slow conda subprocess on every shell

# tabtab source for electron-forge package
# uninstall by removing these lines or running `tabtab uninstall electron-forge`
[ -f "$HOME/.npm/_npx/6913fdfd1ea7a741/node_modules/tabtab/.completions/electron-forge.fish" ]; and . "$HOME/.npm/_npx/6913fdfd1ea7a741/node_modules/tabtab/.completions/electron-forge.fish"

fish_add_path $HOME/.local/bin

# OpenClaw Completion
if test -f "$HOME/.openclaw/completions/openclaw.fish"
    source "$HOME/.openclaw/completions/openclaw.fish"
end

function tmux-ego
    if tmux has-session -t ego 2>/dev/null
        if set -q TMUX
            tmux switch-client -t ego
        else
            tmux attach -t ego
        end
    else
        tmux new -s ego -c ~/git-repos/ego
    end
end

function tmux-personal
    if tmux has-session -t personal 2>/dev/null
        if set -q TMUX
            tmux switch-client -t personal
        else
            tmux attach -t personal
        end
    else
        tmux new -s personal
    end
end

function tmux-nexus
    ~/.local/bin/tmux-nexus $argv
end

function nexus
    cd /Users/banyar/git-repos/nexus/hermes-agent
    set -lx HERMES_HOME /Users/banyar/git-repos/nexus-instance
    ./.venv/bin/hermes $argv
end

function nexus-browser
    ~/.local/bin/nexus-browser $argv
end

function nexus-claude
    ~/.local/bin/nexus-claude $argv
end

function tmux-immvrse
    if tmux has-session -t immvrse 2>/dev/null
        if set -q TMUX
            tmux switch-client -t immvrse
        else
            tmux attach -t immvrse
        end
    else
        tmux new -s immvrse -c ~/git-repos/immvrse
    end
end

# Syntax highlighting + pager colors (inlined from fish 4.3 frozen-theme migration)
set --global fish_color_autosuggestion brblack
set --global fish_color_cancel -r
set --global fish_color_command blue
set --global fish_color_comment red
set --global fish_color_cwd green
set --global fish_color_cwd_root red
set --global fish_color_end green
set --global fish_color_error brred
set --global fish_color_escape brcyan
set --global fish_color_history_current --bold
set --global fish_color_host normal
set --global fish_color_host_remote yellow
set --global fish_color_normal normal
set --global fish_color_operator brcyan
set --global fish_color_param cyan
set --global fish_color_quote yellow
set --global fish_color_redirection cyan --bold
set --global fish_color_search_match white --background=brblack
set --global fish_color_selection white --bold --background=brblack
set --global fish_color_status red
set --global fish_color_user brgreen
set --global fish_color_valid_path --underline
set --global fish_pager_color_completion normal
set --global fish_pager_color_description yellow -i
set --global fish_pager_color_prefix normal --bold --underline
set --global fish_pager_color_progress brwhite --background=cyan
set --global fish_pager_color_selected_background -r
