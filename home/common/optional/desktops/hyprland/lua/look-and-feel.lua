-- 10-look-and-feel.lua --------------------------------------------------------
-- Monitors, environment, input, and everything visual.
-- Host-specific values come from 00-vars.lua, which Nix generates.

local vars = require("00-vars")

------------------------------------------------------------
-- DEBUG
------------------------------------------------------------
hl.config({
  debug = { full_cm_proto = true },
})

------------------------------------------------------------
-- MONITORS
------------------------------------------------------------
-- vars.monitors is a list of tables; one hl.monitor() call each.
-- Calls are cumulative, so adding a monitor is just another entry in Nix.
for _, m in ipairs(vars.monitors) do
  hl.monitor(m)
end

------------------------------------------------------------
-- ENV
------------------------------------------------------------
hl.env("XCURSOR_SIZE", "24")
hl.env("WLR_DRM_DEVICES", "/dev/dri/card0:/dev/dri/card1")

------------------------------------------------------------
-- INPUT
------------------------------------------------------------
hl.config({
  input = {
    kb_layout = "us",
    kb_variant = "",
    kb_model = "",
    kb_rules = "",
    kb_options = vars.kb_options, -- caps:escape
    numlock_by_default = true,
    natural_scroll = false,
    follow_mouse = 1,
    touchpad = { natural_scroll = true },
    sensitivity = vars.sensitivity,
  },
})

-- Touchpad workspace swipe (laptop only; vars.gestures is false on the PC).
if vars.gestures then
  hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
end

------------------------------------------------------------
-- GENERAL / GROUP / DECORATION / MISC
------------------------------------------------------------
local c = vars.colors

hl.config({
  general = {
    gaps_in = 0,
    gaps_out = 0,
    border_size = 0,
    col = {
      active_border = c.mauve,
      inactive_border = c.surface0,
    },
    layout = "dwindle",
  },

  group = {
    col = {
      border_active = c.mauve,
      border_inactive = c.surface0,
    },
    groupbar = {
      font_family = "IosevkaTerm",
      font_size = vars.groupbar_font_size,
      gradients = true,
      text_color = c.crust,
      col = {
        active = c.mauve,
        inactive = c.overlay0,
      },
    },
  },

  decoration = {
    rounding = 0,
    active_opacity = 1.0,
    -- inactive_opacity = 0.85,
    dim_inactive = true,
    dim_strength = 0.1,
    blur = {
      enabled = true,
      size = 8,
      passes = 2,
      popups = true,
    },
  },

  binds = {
    movefocus_cycles_fullscreen = false,
    workspace_center_on = 1,
    focus_preferred_method = 0,
  },

  dwindle = {
    force_split = 0,
    default_split_ratio = 1.0,
  },

  master = {
    new_status = "slave",
  },

  misc = {
    disable_hyprland_logo = true,
    mouse_move_enables_dpms = true,
    key_press_enables_dpms = true,
  },

  -- The update/donation nag screens (hyprland-update-screen,
  -- hyprland-donate-screen from hyprland-guiutils) get spawned before the
  -- Wayland socket is up, so they immediately fail to connect and abort --
  -- taking the whole compositor service down with them on every login.
  -- Disabling both avoids the crash entirely.
  ecosystem = {
    no_update_news = true,
    no_donation_nag = true,
  },
})

------------------------------------------------------------
-- ANIMATIONS
------------------------------------------------------------
hl.animation({ leaf = "global", enabled = true, speed = 3, bezier = "default" })

-- Custom curves live here if you ever want them, e.g.
-- hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })
-- hl.animation({ leaf = "windows", enabled = true, speed = 4, bezier = "quick" })
