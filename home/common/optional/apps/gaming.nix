{...}: {
  programs.mangohud = {
    enable = true;
    # The performance overlay: steam-full shows it on every game, and plain
    # `mangohud %command%` uses it too. Keys are anything MangoHud.conf takes
    # (https://github.com/flightlessmango/MangoHud#hud-configuration); true
    # shows a metric, false hides it, anything else becomes key=value.
    settings = {
      # One small line in the top-left: FPS, CPU load, GPU load.
      position = "top-left";
      horizontal = true;
      table_columns = 20; # wide enough that horizontal never wraps
      legacy_layout = false;
      fps = true;
      cpu_stats = true;
      gpu_stats = true;
      frametime = false; # the ms figure next to FPS
      frame_timing = false; # the frametime graph

      font_size = 18;
      background_alpha = 0.4;
    };
  };

  home.shellAliases = {
    hytale = "flatpak run com.hypixel.HytaleLauncher";
  };
}
