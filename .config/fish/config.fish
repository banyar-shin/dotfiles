# ~/.config/fish/conf.d runs first

# https://fishshell.com/docs/current/tutorial.html
# https://github.com/jorgebucaran/fish-shell-cookbook
# https://github.com/fish-shell/fish-shell/blob/master/share/config.fish
# https://github.com/fish-shell/fish-shell/blob/da32b6c172dcfe54c9dc4f19e46f35680fc8a91a/share/config.fish#L257-L269

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if test -f /Users/banyar-ego/miniconda3/bin/conda
    eval /Users/banyar-ego/miniconda3/bin/conda "shell.fish" hook $argv | source
else
    if test -f "/Users/banyar-ego/miniconda3/etc/fish/conf.d/conda.fish"
        . "/Users/banyar-ego/miniconda3/etc/fish/conf.d/conda.fish"
    else
        set -x PATH /Users/banyar-ego/miniconda3/bin $PATH
    end
end
# <<< conda initialize <<<

# pnpm
set -gx PNPM_HOME /Users/banyar-ego/Library/pnpm
if not string match -q -- $PNPM_HOME $PATH
    set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

source ~/.config/fish/functions/env-switch.fish

# tabtab source for electron-forge package
# uninstall by removing these lines or running `tabtab uninstall electron-forge`
[ -f /Users/banyar-ego/.npm/_npx/6913fdfd1ea7a741/node_modules/tabtab/.completions/electron-forge.fish ]; and . /Users/banyar-ego/.npm/_npx/6913fdfd1ea7a741/node_modules/tabtab/.completions/electron-forge.fish
