{config, ...}: let
  # Was hardcoded to /home/mrgeotech in four places. This works on any user,
  # and breaks loudly at eval time rather than silently at runtime.
  wallpaperDir = "${config.home.homeDirectory}/.config/hypr";

  wallpapers = [
    "tropic_island_morning.jpg"
    "tropic_island_day.jpg"
    "tropic_island_evening.jpg"
    "tropic_island_night.jpg"
  ];

  path = name: "${wallpaperDir}/${name}";

  # scripts/wallpaper.sh swaps these by time of day; this is just the one
  # loaded at startup before the script runs.
  initial = "tropic_island_night.jpg";
in {
  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = false;

      preload = map path wallpapers;
      wallpaper = [",${path initial}"];
    };
  };
}
