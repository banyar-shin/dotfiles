-- Pull in the wezterm API
local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.color_scheme = "Gruvbox Material (Gogh)"
config.font_size = 16.0
config.font = wezterm.font("CaskaydiaCove Nerd Font")

config.keys = {
	{ key = "Enter", mods = "ALT", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "Enter", mods = "ALT|SHIFT", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },

	-- Tab cycling
	{ key = "Tab", mods = "ALT", action = wezterm.action.ActivateTabRelative(1) },
	{ key = "Tab", mods = "ALT|SHIFT", action = wezterm.action.ActivateTabRelative(-1) },

	-- Pane cycling (moved to brackets)
	{ key = "]", mods = "ALT", action = wezterm.action.ActivatePaneDirection("Next") },
	{ key = "[", mods = "ALT", action = wezterm.action.ActivatePaneDirection("Prev") },

	-- Close current pane
	{ key = "w", mods = "ALT", action = wezterm.action.CloseCurrentPane({ confirm = true }) },

	-- Move tabs
	{ key = "<", mods = "ALT|SHIFT", action = wezterm.action.MoveTabRelative(-1) },
	{ key = ">", mods = "ALT|SHIFT", action = wezterm.action.MoveTabRelative(1) },
}

return config
