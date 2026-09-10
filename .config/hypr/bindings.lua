-- :: Keybindings :: -----------------------------------------------------------
-- stylua: ignore file
-- bind table keys:
--   locked        works also when an input inhibitor (e.g. a lockscreen) is active
--   release       trigger on release of a key
--   repeating     repeat when held
--   non_consuming key/mouse events are also passed to the active window
--   mouse         see move/resize binds below
--   transparent   cannot be shadowed by other binds
--   ignore_mods   ignore modifiers

-- stylua: ignore start
local MOD   = "SUPER"
local MEH   = "CTRL + SHIFT + ALT"
local HYPER = MOD .. " + " .. MEH

local HOME  = os.getenv("HOME")

local dsp  = hl.dsp
local bind = hl.bind
local cmd  = dsp.exec_cmd
local mon  = require("monitors")

local hold = { locked = true, repeating = true }
local lock = { locked = true }
local drag = { mouse = true }
local held = { repeating = true }

local function key(...)
	return table.concat({ ... }, " + ")
end

local function script(name)
	return HOME .. "/.config/hypr/scripts/" .. name
end

local function resize(x, y)
	return dsp.window.resize({ x = x, y = y, relative = true })
end

local function fullscreen(client)
	return dsp.window.fullscreen_state({ action = "toggle", internal = 2, client = client })
end

-- hy3 is loaded by `hyprpm reload` after the first parse. Look it up at
-- keypress time and pcall the dispatcher: a stale plugin must not throw
-- out of the bind and leave the key dead. fallback is a built-in dsp.
local function hy3(make, fallback)
	return function()
		local plugin = hl.plugin and hl.plugin.hy3
		if plugin then
			local ok = pcall(function() hl.dispatch(make(plugin)) end)
			if ok then return end
		end
		if fallback then hl.dispatch(fallback) end
	end
end

local function hy3call(name, arg, fallback)
	return hy3(function(p) return p[name](arg) end, fallback)
end

-- :: Multimedia Keys :: -------------------------------------------------------
bind("XF86MonBrightnessDown", cmd("brillo -u 50000 -q -U 5"), hold)
bind("XF86MonBrightnessUp",   cmd("brillo -u 50000 -q -A 5"), hold)

local sink   = "@DEFAULT_AUDIO_SINK@"
local source = "@DEFAULT_AUDIO_SOURCE@"
bind("XF86AudioRaiseVolume", cmd("wpctl set-volume " .. sink   .. " 5%+ -l 1.2"), hold)
bind("XF86AudioLowerVolume", cmd("wpctl set-volume " .. sink   .. " 5%-"),        hold)
bind("XF86AudioMute",        cmd("wpctl set-mute   " .. sink   .. " toggle"),     hold)
bind("XF86AudioMicMute",     cmd("wpctl set-mute   " .. source .. " toggle"),     hold)

-- pause all players simultaneously
bind("SHIFT + XF86AudioPlay", cmd("playerctl -a pause; mpc -q pause"), lock)

-- control players according to specific priority (if running)
local player = script("player-control.sh")
bind("XF86AudioPlay", cmd(player .. " play"), lock)
bind("XF86AudioNext", cmd(player .. " next"), lock)
bind("XF86AudioPrev", cmd(player .. " prev"), lock)

-- print screen
bind("Print",                cmd("slurp | grim -g - $HOME/$(date +'screenshot_%Y-%m-%d-%H%M%S.png')"))
bind(key(MOD, "SHIFT", "P"), cmd("slurp | grim -g - $HOME/$(date +'screenshot_%Y-%m-%d-%H%M%S.png')"))

-- :: WM & Status Bar :: -------------------------------------------------------
bind(key(MEH, "M"), mon.apply) -- auto re-apply; named: hyprctl eval 'require("monitors").apply("dock-xiaomi")'
bind(key(MEH, "E"),          dsp.exit())
bind(key(MOD, "ESCAPE"),     cmd("pkill wlogout || wlogout"))
bind(key(MOD, "SHIFT", "R"), cmd("hyprctl reload"))
bind(key(MOD, "SHIFT", "Q"), dsp.window.close())
bind(key(MOD, "SHIFT", "B"), cmd("killall waybar || waybar"))
bind(key(MOD, "SHIFT", "X"), cmd("hyprlock"))
bind(key(MOD, "SHIFT", "W"), cmd(script("change_wallpaper.sh")))

-- :: Apps :: ------------------------------------------------------------------
bind(key(MOD, "Return"),    cmd("kitty"))
bind(key(HYPER, "W"),       cmd("warpd --hint2 --oneshot"))
bind(key(MOD, "D"),         cmd("pkill wofi || wofi --show drun"))
bind(key(MOD, "C"),         cmd("pkill wofi || cliphist list | wofi -d | cliphist decode | wl-copy"))
bind(key(MOD, "ALT", "B"),  cmd("pkill rofi-rbw && pkill wofi || rofi-rbw"))

-- :: Layout Shortcuts :: ------------------------------------------------------
-- NOTE: workaround for https://github.com/outfoxxed/hy3/issues/2
local hy3_movewindow = script("hy3-movewindow.sh")

local arrows = {
	{ name = "left",  short = "l" },
	{ name = "right", short = "r" },
	{ name = "up",    short = "u" },
	{ name = "down",  short = "d" },
}

local function move_window(short, name)
	return function()
		if hl.plugin and hl.plugin.hy3 then
			hl.exec_cmd(hy3_movewindow .. " " .. short)
			return
		end
		hl.dispatch(dsp.window.move({ direction = name }))
	end
end

for _, a in ipairs(arrows) do
	bind(key(MOD, a.name),          hy3call("move_focus", a.short, dsp.focus({ direction = a.name })))
	bind(key(MOD, "SHIFT", a.name), move_window(a.short, a.name))
end

-- switch workspaces with mod + [0-9]
-- move active window to a workspace with mod + SHIFT + [0-9]
for i = 1, 10 do
	local n = i % 10
	bind(key(MOD, n),          dsp.focus({ workspace = i }))
	bind(key(MOD, "SHIFT", n), dsp.window.move({ workspace = i, follow = false }))
end

-- hy3 switch to tab (built-in group index if hy3 is missing)
for i = 1, 10 do
	local n = i % 10
	bind(key(MOD, "CTRL", n), hy3call("focus_tab", { index = i }, dsp.group.active({ index = i })))
end

-- move active workspace to next monitor (cyclic)
-- NOTE: use combi-command to fix focus!
bind(key(MOD, "M"), dsp.workspace.move({ monitor = "+1" }))

-- toggle focused window as sticky
bind(key(MOD, "Plus"), dsp.window.pin())

-- special workspace (scratchpad)
bind(key(MOD, "Minus"),         dsp.workspace.toggle_special("magic"))
bind(key(MOD, "SHIFT", "Minus"), dsp.window.move({ workspace = "special:magic" }))

-- fullscreen and floating
bind(key(MOD, "SPACE"),     dsp.window.float({ action = "toggle" }))
bind(key(MOD, "F"),         fullscreen(0))
bind(key(MOD, "SHIFT", "F"), fullscreen(2))

-- scroll through existing workspaces with mod + scroll
bind(key(MOD, "mouse_down"), dsp.focus({ workspace = "e+1" }))
bind(key(MOD, "mouse_up"),   dsp.focus({ workspace = "e-1" }))

-- move/resize windows with mod + LMB/RMB and dragging
bind(key(MOD, "mouse:272"), dsp.window.drag(),   drag)
bind(key(MOD, "mouse:273"), dsp.window.resize(), drag)

-- hy3-only: expand / h-v-tab groups. T falls back to built-in tab groups.
bind(key(MOD, "E"),         hy3call("expand",      "expand"))
bind(key(MOD, "W"),         hy3call("expand",      "base"))
bind(key(MOD, "H"),         hy3call("make_group",  "h"))
bind(key(MOD, "V"),         hy3call("make_group",  "v"))
bind(key(MOD, "T"),         hy3call("make_group",  "tab", dsp.group.toggle()))
bind(key(MOD, "SHIFT", "T"), hy3call("change_group", "toggletab"))

-- window overview
-- bind(key(MOD, "Tab"), ...) -- hyprexpo:expo toggle

-- resize mode submap
bind(key(MOD, "R"), dsp.submap("resize"))
hl.define_submap("resize", function()
	bind("right",        resize( 200,    0), held)
	bind("left",         resize(-200,    0), held)
	bind("up",           resize(   0, -200), held)
	bind("down",         resize(   0,  200), held)
	bind("SHIFT + right", resize(  10,    0), held)
	bind("SHIFT + left",  resize( -10,    0), held)
	bind("SHIFT + up",    resize(   0,  -10), held)
	bind("SHIFT + down",  resize(   0,   10), held)
	bind("escape", dsp.submap("reset"))
	bind("return", dsp.submap("reset"))
end)

-- stylua: ignore end
