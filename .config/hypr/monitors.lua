-- :: Monitors :: --------------------------------------------------------------
-- Native hl.monitor() rules (not wlr-output-management).
-- Hotplug: first matching profile in PROFILES (auto).
-- Named:  mon dock-mi  →  hyprctl eval 'require("monitors").apply(...)'
-- prefs.dock = mi | mi-laptop | dual. Mi @50 — @60 ENOSPCs AOC on this dock.

-- stylua: ignore start
local STATE = os.getenv("HOME") .. "/.config/hypr/.monitor-prefs.lua"
local MI    = "3440x1440@50.00Hz"

-- :: Prefs :: -----------------------------------------------------------------
local prefs = { dock = "mi", arzopa = "right", office = "right" }
do
	local ok, saved = pcall(dofile, STATE)
	if ok and type(saved) == "table" then
		for k, v in pairs(saved) do prefs[k] = v end
	end
end

local function remember(key, val)
	if prefs[key] == val then return end
	prefs[key] = val
	local f = io.open(STATE, "w")
	if not f then return end
	f:write(string.format(
		"return { dock = %q, arzopa = %q, office = %q }\n",
		prefs.dock, prefs.arzopa, prefs.office
	))
	f:close()
end

-- :: Heads :: -----------------------------------------------------------------
local function has(m, needle)
	return m and ((m.description or "") .. "\n" .. (m.name or "")):find(needle, 1, true)
end

-- get_monitors() omits disabled heads (no all=true). skip virtual FALLBACK.
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

-- Framework 2256/1.175 = 1920 logical
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
local function on(m, pos, scale, mode)
	hl.monitor({
		output   = m.name,
		disabled = false,
		mode     = mode or "preferred",
		position = pos or "0x0",
		scale    = scale or 1,
	})
end

-- monitor table or output string; nil = no-op. Lid often already off → "eDP-1".
local function off(m)
	local name = type(m) == "string" and m or m and m.name
	if name then hl.monitor({ output = name, disabled = true }) end
end

local function take_over(external, mode)
	on(external, "0x0", 1, mode)
	off("eDP-1")
end

local function toast(name)
	pcall(function()
		hl.notification.create({
			text      = "Profile " .. name,
			timeout   = 2500,
			icon      = "info",
			font_size = 24,
			color     = "rgba(33ccffee)",
		})
	end)
end

-- :: Profiles :: --------------------------------------------------------------
-- have / auto / pick / run. Disabled heads are invisible here — `mon` enables
-- them in a separate hyprctl before apply (nested hyprctl deadlocks).
local PROFILES = {
	{
		name = "dock-dual",
		have = function(c) return c.xiaomi and c.aoc end,
		auto = function(c) return c.xiaomi and c.aoc and prefs.dock == "dual" end,
		pick = function() remember("dock", "dual") end,
		run  = function(c)
			on(c.xiaomi, "2560x0", 1, MI)
			on(c.aoc,    "0x0")
			off(c.laptop or "eDP-1")
		end,
	},
	{
		name = "dock-mi",
		have = function(c) return c.xiaomi end,
		auto = function(c) return c.xiaomi and prefs.dock ~= "mi-laptop" end,
		pick = function() remember("dock", "mi") end,
		run  = function(c)
			on(c.xiaomi, "0x0", 1, MI)
			off(c.aoc)
			off(c.laptop or "eDP-1")
		end,
	},
	{
		name = "dock-mi-laptop",
		have = function(c) return c.xiaomi end,
		auto = function(c) return c.xiaomi and prefs.dock == "mi-laptop" end,
		pick = function() remember("dock", "mi-laptop") end,
		run  = function(c)
			on(c.laptop or { name = "eDP-1" }, "3440x0", c.scale)
			on(c.xiaomi, "0x0", 1, MI)
			off(c.aoc)
		end,
	},
	{
		-- auto = false: otherwise have() steals hotplug when Mi is disabled
		name = "dock-aoc",
		have = function(c) return c.aoc end,
		auto = function() return false end,
		run  = function(c)
			off(c.xiaomi)
			take_over(c.aoc)
		end,
	},
	{
		name = "Iiyama",
		have = function(c) return c.iiyama end,
		run  = function(c) take_over(c.iiyama) end,
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
-- apply() / apply("dock-dual"). bind may pass a non-string → treat as auto.
local last_name = ""
local suppress_auto = false -- named modeset → monitor.added must not stomp prefs
local gen = 0

local function apply(want)
	if type(want) ~= "string" then want = nil end
	if not want and suppress_auto then return end
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
				gen = gen + 1
				suppress_auto = true
				hl.timer(function() suppress_auto = false end, { timeout = 3000, type = "oneshot" })
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
