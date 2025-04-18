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

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

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

source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.config/p10k/mac.p10k.zsh ]] || source ~/.config/p10k/mac.p10k.zsh

alias config='/usr/bin/git --git-dir=/Users/banyar/.cfg/ --work-tree=/Users/banyar'

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
__conda_setup="$('/Users/banyar-ego/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/banyar-ego/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/banyar-ego/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/banyar-ego/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

