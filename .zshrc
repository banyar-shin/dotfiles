# What OS are we running?
if [[ $(uname) == "Darwin" ]]; then
    source ~/mac.zsh

elif command -v freebsd-version > /dev/null; then
    source "$ZSH_CUSTOM"/os/freebsd.zsh

elif command -v apt > /dev/null; then
    source ~/linux.zsh

else
    echo 'Unknown OS!'
fi
