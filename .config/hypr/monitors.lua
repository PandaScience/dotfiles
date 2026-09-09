-- :: Monitors :: --------------------------------------------------------------
-- Fallback only. shikane configures displays over wlr-output-management and
-- Hyprland lets that state override these rules for as long as shikane is
-- connected (https://github.com/hyprwm/Hyprland/pull/14343), so the only job
-- here is keeping a built-in panel usable when shikane is not running.
-- Everything else (modes, positions, enabling/disabling) belongs in
-- ~/.config/shikane/config.toml.

-- Any display without a rule of its own.
hl.monitor({
  output = "",
  mode = "preferred",
  position = "auto",
  scale = "auto",
})

-- Built-in panel. auto guesses 1.5 here, which is too big.
hl.monitor({
  output = "eDP-1",
  scale = 1,
})

-- The other laptop's panel is a BOE and wants a different scale. This has to
-- stay below the eDP-1 rule: Hyprland matches last-wins and takes the last
-- matching rule, so on that machine this one wins over the generic one above.
hl.monitor({
  output = "desc:BOE",
  scale = 1.175,
})
