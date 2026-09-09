-- :: Window Properties :: -----------------------------------------------------
-- stylua: ignore start
-- define floating windows (search for "class" in `hyprctl clients`)
hl.window_rule({ match = { class = "pavucontrol" },           float = true })
hl.window_rule({ match = { class = "blueman-manager" },       float = true })
hl.window_rule({ match = { class = "nm-connection-editor" },  float = true })
hl.window_rule({ match = { class = "Pinentry-gtk-2" },        float = true })
hl.window_rule({ match = { class = "hyprland-share-picker" }, float = true })
hl.window_rule({
	match = { class = "org.keepassxc.KeePassXC", title = "(.*)Access Request" },
	float = true,
})

-- no_gaps_when_only replacement, see
-- https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/#smart-gaps-ignoring-special-workspaces
hl.workspace_rule({ workspace = "w[tv1]s[false]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]s[false]",   gaps_out = 0, gaps_in = 0 })
hl.window_rule({ match = { float = false, workspace = "w[tv1]s[false]" }, border_size = 0 })
hl.window_rule({ match = { float = false, workspace = "w[tv1]s[false]" }, rounding    = 0 })
hl.window_rule({ match = { float = false, workspace = "f[1]s[false]" },   border_size = 0 })
hl.window_rule({ match = { float = false, workspace = "f[1]s[false]" },   rounding    = 0 })

-- extra thick border for floating windows in special workspace
-- (border_color is broken here, first color is ignored, need at least 3?)
-- hl.window_rule({ match = { workspace = "s[true]", float = true }, border_size = 4 })
hl.window_rule({
	match = { workspace = "s[true]", float = true },
	border_size = 4,
	border_color = "rgb(ff0000) rgba(ff9f1c99) rgba(ff000099) 45deg",
})
-- stylua: ignore end

-- :: Toolkit Config :: --------------------------------------------------------
-- unscale XWayland: https://wiki.hypr.land/Configuring/Advanced-and-Cool/XWayland/
hl.config({
	xwayland = {
		force_zero_scaling = true,
	},
})

hl.env("XCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("GDK_SCALE", "1")
-- hl.env("GDK_DPI_SCALE",     "1.2")
-- fcitx config: https://fcitx-im.org/wiki/Using_Fcitx_5_on_Wayland
-- NOTE: QT_IM_MODULE[S], GTK_IM_MODULE or GLFW_IM_MODULE not required.
-- XMODIFIERS only required for XWayland apps like firefox, chromium etc.
hl.env("XMODIFIERS", "@im=fcitx")

-- :: Decoration :: ------------------------------------------------------------
-- layout lives here because this hl.config writes `general`. plugins.lua
-- still loads first so plugin keys exist; pick hy3 only if that apply worked.
local ok_hy3, hy3 = pcall(function() return hl.plugin and hl.plugin.hy3 end)
local layout = (ok_hy3 and hy3) and "hy3" or "dwindle"

hl.config({
	general = {
		gaps_in = 3,
		gaps_out = 5,
		border_size = 2,
		col = {
			active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
			inactive_border = "rgba(595959aa)",
		},
		layout = layout,
		-- Please see https://wiki.hypr.land/configuring/extra/tearing/#enabling-tearing before you turn this on
		allow_tearing = false,
	},
	decoration = {
		rounding = 2,
		blur = {
			enabled = true,
			size = 3,
			passes = 3,
			noise = 0.3,
			contrast = 0.9,
			brightness = 0.9,
		},
		shadow = {
			enabled = true,
			range = 4,
			render_power = 3,
			color = "rgba(1a1a1aee)",
		},
	},
	animations = {
		enabled = true,
	},
	binds = {
		workspace_back_and_forth = true,
	},
	dwindle = {
		preserve_split = true,
	},
})

-- :: Animations :: ------------------------------------------------------------
-- stylua: ignore start
hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })

hl.animation({ leaf = "windows",     enabled = true, speed =  7, bezier = "myBezier" })
-- hl.animation({ leaf = "windowsOut", enabled = true, speed =  7, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border",      enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed =  8, bezier = "default" })
hl.animation({ leaf = "fade",        enabled = true, speed =  7, bezier = "default" })
hl.animation({ leaf = "workspaces",  enabled = true, speed =  3, bezier = "default" })
hl.animation({
	leaf = "specialWorkspace",
	enabled = true,
	speed = 5,
	bezier = "default",
	style = "fade",
})
-- stylua: ignore end
