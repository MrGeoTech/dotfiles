-- 20-rules.lua ----------------------------------------------------------------
-- Window and layer rules. Rules now take a `name`, which shows up in
-- `hyprctl rules` and makes them addressable at runtime.

-- Dim the desktop behind rofi.
hl.window_rule({
  name = "dim-around-rofi",
  match = { title = "^(.*rofi.*)$" },
  dim_around = true,
})

-- Don't waste blur passes on the window you're actually looking at.
hl.window_rule({
  name = "no-blur-when-focused",
  match = { focus = true },
  no_blur = true,
})

-- Each call returns a handle, so a rule can be flipped off at runtime:
--   local r = hl.window_rule({ ... })
--   r:set_enabled(false)
-- Handy for a "game mode" toggle later on.
