-- 20-rules.lua ----------------------------------------------------------------
-- Window and layer rules. Rules now take a `name`, which shows up in
-- `hyprctl rules` and makes them addressable at runtime.

-- Rofi is a layer surface on Wayland. Blur what's behind its translucent
-- box (ignore_alpha keeps the blur inside the rounded corners) and dim the
-- rest of the desktop so the eye goes straight to it.
hl.layer_rule({
  name = "glass-rofi",
  match = { namespace = "^rofi$" },
  blur = true,
  ignore_alpha = 0.01,
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
