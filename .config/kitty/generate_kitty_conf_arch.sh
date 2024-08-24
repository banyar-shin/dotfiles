#!/bin/sh

# Ensure the environment variable is set
if command -v pacman >/dev/null; then
  export KITTY_FONT_SIZE=14.0

elif [[ $(uname) == "Darwin" ]]; then
  export KITTY_FONT_SIZE=18.0

fi

# Substitute the environment variable in the template
envsubst <~/.config/kitty/kitty.conf.template >~/.config/kitty/kitty.conf
