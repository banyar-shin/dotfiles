# What OS are we running?
if [[ $(uname) == "Darwin" ]]; then
    source ~/.config/zsh/mac.zsh

elif command -v freebsd-version > /dev/null; then
    source "$ZSH_CUSTOM"/os/freebsd.zsh

elif command -v apt > /dev/null; then
    source ~/.config/zsh/wsl.zsh

else
    echo 'Unknown OS!'
fi
