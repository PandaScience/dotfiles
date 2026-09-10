local function run(cmds)
	for _, cmd in ipairs(cmds) do
		hl.exec_cmd(cmd)
	end
end

-- :: Autostart Apps (only once during startup) :: -----------------------------
hl.on("hyprland.start", function()
	run({
		"dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP",
		-- reload after hyprpm so the next parse sees hl.plugin.hy3
		"hyprpm reload -n && hyprctl reload",
		"hyprctl setcursor Bibata-Modern-Classic 24",
		"hypridle",
		"waybar",
		"dunst",
		"nm-applet --indicator",
		"sleep 3 && blueman-applet",
		"gammastep-indicator",
		"sleep 3 && keepassxc", -- wait till waybar is loaded so the tray icon is visible
		"udiskie --smart-tray --appindicator",
		"easyeffects --gapplication-service && easyeffects -l lappy_mctopface",
		-- 2.3.0: x-kde-passwordManagerHint → CLIPBOARD_STATE=sensitive (#177);
		-- cliphist 0.7 skips those (KeePassXC sets the hint)
		"wl-paste --type text  --watch cliphist store",
		"wl-paste --type image --watch cliphist store",
	})
end)

-- :: Autoreload Apps (on every reload) :: -------------------------------------
run({
	"~/.config/hypr/scripts/init_wallpaper.sh",
})
