-- 40-autostart.lua ------------------------------------------------------------
-- Loaded last, so everything else is configured before anything launches.

local vars = require("00-vars")

local browser = os.getenv("BROWSER") or "firefox"

hl.on("hyprland.start", function()
  -- hyprpaper and hypridle are started by their home-manager systemd user
  -- services (services.hyprpaper.enable / services.hypridle.enable), and
  -- gnome-keyring by services.gnome-keyring.enable. Launching them here too
  -- gives you two of each. Uncomment only if you drop the HM services.
  -- hl.exec_cmd("hyprpaper")
  -- hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")

  hl.exec_cmd("systemctl --user start hyprpolkitagent")
  hl.exec_cmd("sh " .. vars.home .. "/.config/hypr/scripts/wallpaper.sh")
  hl.exec_cmd(browser)

  -- Long-bracket strings mean no backslash-escaping the inner quotes.
  hl.exec_cmd([[bash -c "sleep 0.5 && hyprlock"]])
end)
