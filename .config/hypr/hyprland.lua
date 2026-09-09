-- :: Source Configs :: --------------------------------------------------------
require("plugins") -- hyprpm plugin settings (before binds / layout use them)
require("monitors") -- monitor rules / shikane fallback
require("autostart") -- exec and exec-once apps
require("bindings") -- keybindings
require("appearance") -- decoration and animation
require("input") -- keyboard, mouse & touch

hl.config({
	debug = {
		disable_logs = false,
		disable_time = false,
	},
})
