-- Pull in the wezterm API
local wezterm = require("wezterm")

local config = wezterm.config_builder()

local scheme_dark = "Gruvbox Material (Gogh)"
local scheme_light = "Gruvbox Light"
config.color_scheme = scheme_dark

config.term = "xterm-256color"
config.enable_kitty_keyboard = true

config.font_size = 16.0
config.font = wezterm.font("CaskaydiaCove Nerd Font")

config.keys = {
	-- Toggle light/dark (WezTerm + Oh My Posh)
	{
		key = "d",
		mods = "ALT|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			local overrides = window:get_config_overrides() or {}
			local mode
			if overrides.color_scheme == scheme_light then
				overrides.color_scheme = scheme_dark
				mode = "dark"
			else
				overrides.color_scheme = scheme_light
				mode = "light"
			end
			window:set_config_overrides(overrides)

			-- Write mode file and reload prompt in all panes
			local home = os.getenv("HOME")
			local f = io.open(home .. "/.config/theme-mode", "w")
			if f then
				f:write(mode)
				f:close()
			end

			-- Only reload prompt if pane is at an idle shell
			local process = pane:get_foreground_process_name() or ""
			local shell = process:match("([^/]+)$") or ""
			local shells = { fish = true, zsh = true, bash = true, sh = true }
			if shells[shell] then
				pane:send_text("theme-reload\n")
			end
		end),
	},
	{ key = "t", mods = "CTRL", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
	{ key = "Enter", mods = "CTRL", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "Enter", mods = "CTRL|SHIFT", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "Enter", mods = "ALT", action = wezterm.action.SendKey({ key = "Enter", mods = "ALT" }) },
	{ key = "\\", mods = "ALT", action = wezterm.action.SendKey({ key = "\\", mods = "ALT" }) },
	{ key = "Tab", mods = "CTRL", action = wezterm.action.ActivateTabRelative(1) },
	{ key = "Tab", mods = "CTRL|SHIFT", action = wezterm.action.ActivateTabRelative(-1) },

	-- Pane cycling uses Ctrl so Option can belong to tmux.
	{ key = "]", mods = "CTRL", action = wezterm.action.ActivatePaneDirection("Next") },
	{ key = "[", mods = "CTRL", action = wezterm.action.ActivatePaneDirection("Prev") },

	-- Close current pane with the WezTerm scope key.
	{ key = "w", mods = "CTRL", action = wezterm.action.CloseCurrentPane({ confirm = true }) },
	{
		key = "w",
		mods = "CMD",
		action = wezterm.action_callback(function(window, pane)
			local process = pane:get_foreground_process_name() or ""
			local program = process:match("([^/]+)$") or ""
			if program == "tmux" then
				window:perform_action(wezterm.action.SendKey({ key = "a", mods = "CTRL" }), pane)
				window:perform_action(wezterm.action.SendKey({ key = "d" }), pane)
			else
				window:perform_action(wezterm.action.CloseCurrentTab({ confirm = true }), pane)
			end
		end),
	},

	-- Move tabs with the WezTerm scope key.
	{ key = "<", mods = "CTRL|SHIFT", action = wezterm.action.MoveTabRelative(-1) },
	{ key = ">", mods = "CTRL|SHIFT", action = wezterm.action.MoveTabRelative(1) },
}

return config
