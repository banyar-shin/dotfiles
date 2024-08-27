#!/bin/sh

# Ensure the environment variable is set
if command -v pacman >/dev/null; then
  echo "kitty.conf generator: Linux detected!"
  export KITTY_FONT_SIZE=12.0
  echo "Font size set to 12.0"

elif [[ $(uname) == "Darwin" ]]; then
  echo "kitty.conf generator: MacOS detected!"
  export KITTY_FONT_SIZE=18.0
  echo "Font size set to 18.0"

fi

# Substitute the environment variable in the template
envsubst <~/.config/kitty/kitty.conf.template >~/.config/kitty/kitty.conf
