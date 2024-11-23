-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = "Gruvbox Material (Gogh)"

config.font_size = 18.0
config.font = wezterm.font("CaskaydiaCove Nerd Font")

-- and finally, return the configuration to wezterm
return config
