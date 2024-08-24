# What OS are we running?
if [[ $(uname) == "Darwin" ]]; then
    source ~/.config/zsh/mac.zsh

elif command -v pacman > /dev/null; then
    source ~/.config/zsh/arch.zsh
    
elif command -v freebsd-version > /dev/null; then
    source "$ZSH_CUSTOM"/os/freebsd.zsh

else
    echo 'Unknown OS!'
fi
