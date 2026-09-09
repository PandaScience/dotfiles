-- :: Hyprpm Plugin Config :: --------------------------------------------------

-- plugin installation:
--   hyprpm add <github-url>
--   hyprpm enable <plugin>
--   hyprpm update
--   hyprpm list

-- Lua aborts the whole config on an unknown plugin key (hyprlang kept
-- going). Apply hy3 only when the plugin is loaded; pcall the map so a
-- version skew cannot take down binds / decoration / input.

local ok, hy3 = pcall(function() return hl.plugin and hl.plugin.hy3 end)
if not ok or not hy3 then return end

-- https://github.com/outfoxxed/hy3
-- layout is set in appearance.lua (same general table as gaps / borders)
pcall(hl.config, {
	plugin = {
		hy3 = {
			no_gaps_when_only = true,
			autotile = {
				enable = true,
				trigger_width = 800,
				trigger_height = 500,
			},
			tabs = {
				height = 5,
				padding = 8,
				render_text = false,
			},
		},
	},
})
