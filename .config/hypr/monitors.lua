-- :: Monitors :: --------------------------------------------------------------
-- Native hl.monitor() rules (not wlr-output-management).
-- Auto-detect = connected set. Ambiguous layouts = prefs + keybind.
-- Solo Xiaomi: 3440x1440@60 (preferred is 50; 60 works and is easier on the eyes).
-- Dual AOC+Mi on one USB4 cable: Aquamarine REJECTED — not a mode-string bug.
-- $MEH+D flips dual (AOC+Mi).

-- stylua: ignore start
local STATE = os.getenv("HOME") .. "/.config/hypr/.monitor-prefs.lua"

-- :: Prefs :: -----------------------------------------------------------------
-- remembered sides (not detectable from EDID); survive hyprctl reload
local prefs = { dock = "center", arzopa = "right", office = "right" }
do
	local ok, saved = pcall(dofile, STATE)
	if ok and type(saved) == "table" then
		for k, v in pairs(saved) do prefs[k] = v end
	end
end

-- write a tiny Lua table back to STATE
local function save_prefs()
	local f = io.open(STATE, "w")
	if not f then return end
	f:write(string.format(
		"return { dock = %q, arzopa = %q, office = %q }\n",
		prefs.dock, prefs.arzopa, prefs.office
	))
	f:close()
end

-- :: Heads :: -----------------------------------------------------------------
-- plain find on description+name; needles like P27h-20 contain '-' (pattern char)
local function has(m, needle)
	return m and ((m.description or "") .. "\n" .. (m.name or "")):find(needle, 1, true)
end

-- Lua get_monitors() has no { all = true }; disabled heads are omitted.
-- skip virtual FALLBACK.
local function heads()
	local ok, mons = pcall(hl.get_monitors)
	if not ok or not mons then return {} end
	local list = {}
	for _, m in ipairs(mons) do
		if m.name and m.name ~= "FALLBACK" then
			table.insert(list, m)
		end
	end
	return list
end

local function find(list, needle)
	for _, m in ipairs(list) do
		if has(m, needle) then return m end
	end
end

-- map hardware → roles. laptop scale: Framework 2256/1.175 = 1920 logical
local function classify(list)
	local laptop = find(list, "LP140WU4-SPK1") or find(list, "BOE") or find(list, "eDP-1")
	return {
		laptop = laptop,
		scale  = has(laptop, "BOE") and 1.175 or 1,
		arzopa = find(list, "ARZOPA"),
		aoc    = find(list, "Q27G2G4"),
		xiaomi = find(list, "Mi Monitor") or find(list, "Xiaomi"),
		iiyama = find(list, "PL3497WQP"),
		p27    = find(list, "P27h-20"),
		s34    = find(list, "S34C65"),
	}
end

-- :: Rules :: -----------------------------------------------------------------
-- full rule every time (mode/pos/scale) so a switch does not inherit leftovers
local function on(m, pos, scale, mode)
	hl.monitor({
		output   = m.name,
		disabled = false,
		mode     = mode or "preferred",
		position = pos or "0x0",
		scale    = scale or 1,
	})
end

-- no-op if m is nil (laptop already gone on undock)
local function off(m)
	if m then hl.monitor({ output = m.name, disabled = true }) end
end

-- light the external first (may overlap 0x0 for a moment), then drop eDP.
-- do not off(laptop) first: last real head → FALLBACK / watchdog.
local function take_over(external, laptop, mode)
	on(external, "0x0", 1, mode)
	off(laptop)
end

local function notify(name)
	pcall(function()
		hl.notification.create({
			text      = "Profile " .. name,
			timeout   = 2500,
			icon      = "ok",
			font_size = 24,
			color     = "rgba(33ccffee)", -- same cyan as active_border
		})
	end)
end

-- :: Apply :: -----------------------------------------------------------------
-- take_over: overlap at 0x0 is fine; it ends when eDP goes off.
-- side-by-side (laptop stays on): move the laptop to its final X first.
local last_name = ""

local function apply()
	local list = heads()
	local c    = classify(list)

	local name
	if c.xiaomi and c.aoc and prefs.dock ~= "center" then
		name = "dock"
		on(c.aoc,    "0x0")
		on(c.xiaomi, "2560x0", 1, "3440x1440@60.00Hz")
		off(c.laptop)

	elseif c.xiaomi then -- AOC not in the Lua list (often still on the dock, disabled)
		name = "dock-xiaomi"
		hl.monitor({ output = "desc:Q27G2G4", disabled = true })
		-- Mi left (main), laptop right — move laptop first so they do not overlap at 0x0
		if c.laptop then on(c.laptop, "3440x0", c.scale) end
		on(c.xiaomi, "0x0", 1, "3440x1440@60.00Hz")
		off(c.aoc)

	elseif c.aoc then
		name = "dock-aoc"
		take_over(c.aoc, c.laptop)

	elseif c.iiyama then
		name = "Iiyama"
		take_over(c.iiyama, c.laptop)

	elseif c.s34 and c.laptop then
		name = "office-wide"
		on(c.laptop, "3440x0", c.scale)
		on(c.s34,    "0x0")

	elseif c.p27 and c.laptop then -- P27h left/right is a pref, not hardware
		if prefs.office == "left" then
			name = "office-left"
			on(c.laptop, "2560x0", c.scale)
			on(c.p27,    "0x0")
		else
			name = "office-right"
			on(c.laptop, "0x0", c.scale)
			on(c.p27,    "1920x0")
		end

	elseif c.arzopa and c.laptop then -- same pair either side; pref only
		if prefs.arzopa == "left" then
			name = "arzopa-left"
			on(c.laptop, "1920x0", c.scale)
			on(c.arzopa, "0x0")
		else
			name = "arzopa-right"
			on(c.laptop, "0x0", c.scale)
			on(c.arzopa, "1920x0")
		end

	elseif c.laptop then
		name = has(c.laptop, "BOE") and "framework" or "t14"
		on(c.laptop, "0x0", c.scale)

	else
		name = "fallback"
		-- last real output vanished; light a built-in before FALLBACK sticks
		hl.monitor({ output = "eDP-1",    disabled = false, mode = "preferred", position = "0x0", scale = 1 })
		hl.monitor({ output = "desc:BOE", disabled = false, mode = "preferred", position = "0x0", scale = 1.175 })
	end

	if name ~= last_name then -- toast only on a profile change, not every hotplug
		last_name = name
		notify(name)
	end
end

-- :: Hooks :: -----------------------------------------------------------------
-- debounce: unplug fires several events; only the last timer (my == gen) applies
-- 2500ms: dock MST enumerates slowly; 400ms was too early and caught 720x400
local gen = 0
local function schedule()
	gen = gen + 1
	local my = gen
	hl.timer(function()
		if my == gen then apply() end
	end, { timeout = 2500, type = "oneshot" })
end

hl.on("monitor.added",   schedule)
hl.on("monitor.removed", schedule)
hl.on("hyprland.start",  apply) -- cold start: parse may run before outputs exist

pcall(apply) -- reload path (start does not fire again); pcall = don't abort config

-- toggle a pref and re-apply (used by $MEH+D/A/O)
local function flip(key, a, b)
	prefs[key] = (prefs[key] == a) and b or a
	save_prefs()
	apply()
end

-- bindings.lua: $MEH+M re-apply, D/A/O flip prefs
return {
	apply         = apply,
	toggle_dock   = function() flip("dock",   "dual",  "center") end,
	toggle_arzopa = function() flip("arzopa", "right", "left") end,
	toggle_office = function() flip("office", "right", "left") end,
}
-- stylua: ignore end
