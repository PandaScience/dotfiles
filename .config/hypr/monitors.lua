-- :: Monitors :: --------------------------------------------------------------
-- Native hl.monitor() rules (not wlr-output-management).
-- Hotplug: first matching profile in PROFILES (auto).
-- Named:  hyprctl eval 'require("monitors").apply("dock-xiaomi")'
--         no-ops + toast (hl.notification) if the required heads are not attached.
-- Solo Xiaomi: 3440x1440@60 (preferred is 50). Dual AOC+Mi: Aquamarine REJECTED.

-- stylua: ignore start
local STATE = os.getenv("HOME") .. "/.config/hypr/.monitor-prefs.lua"
local MI    = "3440x1440@60.00Hz"

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

local function remember(key, val)
	if prefs[key] == val then return end
	prefs[key] = val
	save_prefs()
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

-- toast = Hyprland built-in notification (hl.notification.create), not notify-send
local function toast(name)
	pcall(function()
		hl.notification.create({
			text      = "Profile " .. name,
			timeout   = 2500,
			icon      = "info", -- built-in set is only warn/info/hint/error/question/ok
			font_size = 24,
			color     = "rgba(33ccffee)", -- same cyan as active_border
		})
	end)
end

-- :: Profiles :: --------------------------------------------------------------
-- have: hardware present (named apply). auto: also prefs, first match wins.
-- pick: persist the pref so the next hotplug stays on this side.
local PROFILES = {
	{
		name = "dock",
		have = function(c) return c.xiaomi and c.aoc end,
		auto = function(c) return c.xiaomi and c.aoc and prefs.dock ~= "center" end,
		pick = function() remember("dock", "dual") end,
		run  = function(c)
			on(c.aoc,    "0x0")
			on(c.xiaomi, "2560x0", 1, MI)
			off(c.laptop)
		end,
	},
	{
		name = "dock-xiaomi",
		have = function(c) return c.xiaomi end,
		pick = function() remember("dock", "center") end,
		run  = function(c)
			hl.monitor({ output = "desc:Q27G2G4", disabled = true })
			-- Mi left (main), laptop right — move laptop first so they do not overlap at 0x0
			if c.laptop then on(c.laptop, "3440x0", c.scale) end
			on(c.xiaomi, "0x0", 1, MI)
			off(c.aoc)
		end,
	},
	{
		name = "dock-aoc",
		have = function(c) return c.aoc end,
		run  = function(c) take_over(c.aoc, c.laptop) end,
	},
	{
		name = "Iiyama",
		have = function(c) return c.iiyama end,
		run  = function(c) take_over(c.iiyama, c.laptop) end,
	},
	{
		name = "office-wide",
		have = function(c) return c.s34 and c.laptop end,
		run  = function(c)
			on(c.laptop, "3440x0", c.scale)
			on(c.s34,    "0x0")
		end,
	},
	{
		name = "office-left",
		have = function(c) return c.p27 and c.laptop end,
		auto = function(c) return c.p27 and c.laptop and prefs.office == "left" end,
		pick = function() remember("office", "left") end,
		run  = function(c)
			on(c.laptop, "2560x0", c.scale)
			on(c.p27,    "0x0")
		end,
	},
	{
		name = "office-right",
		have = function(c) return c.p27 and c.laptop end,
		pick = function() remember("office", "right") end,
		run  = function(c)
			on(c.laptop, "0x0", c.scale)
			on(c.p27,    "1920x0")
		end,
	},
	{
		name = "arzopa-left",
		have = function(c) return c.arzopa and c.laptop end,
		auto = function(c) return c.arzopa and c.laptop and prefs.arzopa == "left" end,
		pick = function() remember("arzopa", "left") end,
		run  = function(c)
			on(c.laptop, "1920x0", c.scale)
			on(c.arzopa, "0x0")
		end,
	},
	{
		name = "arzopa-right",
		have = function(c) return c.arzopa and c.laptop end,
		pick = function() remember("arzopa", "right") end,
		run  = function(c)
			on(c.laptop, "0x0", c.scale)
			on(c.arzopa, "1920x0")
		end,
	},
	{
		name = "framework",
		have = function(c) return c.laptop and has(c.laptop, "BOE") end,
		run  = function(c) on(c.laptop, "0x0", c.scale) end,
	},
	{
		name = "t14",
		have = function(c) return c.laptop and not has(c.laptop, "BOE") end,
		run  = function(c) on(c.laptop, "0x0", c.scale) end,
	},
	{
		name = "fallback",
		have = function() return true end,
		run  = function()
			-- last real output vanished; light a built-in before FALLBACK sticks
			hl.monitor({ output = "eDP-1",    disabled = false, mode = "preferred", position = "0x0", scale = 1 })
			hl.monitor({ output = "desc:BOE", disabled = false, mode = "preferred", position = "0x0", scale = 1.175 })
		end,
	},
}

-- :: Apply :: -----------------------------------------------------------------
-- apply()         = auto (hotplug / $MEH+M). bind may pass a non-string; ignore it.
-- apply("dock")   = named; toast (notification) "no dock" if heads missing; remembers pref.
local last_name = ""

local function apply(want)
	if type(want) ~= "string" then want = nil end
	local c = classify(heads())

	local function go(p)
		if want and p.pick then p.pick() end
		p.run(c)
		if p.name ~= last_name then
			last_name = p.name
			toast(p.name)
		end
	end

	if want then
		for _, p in ipairs(PROFILES) do
			if p.name == want then
				if not p.have(c) then toast("no " .. want) return end
				go(p)
				return
			end
		end
		toast("no " .. want)
		return
	end

	for _, p in ipairs(PROFILES) do
		local ok = p.auto or p.have
		if ok(c) then go(p) return end
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

return { apply = apply }
-- stylua: ignore end
