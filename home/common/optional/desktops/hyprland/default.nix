# https://github.com/hyprwm/Hyprland
{pkgs, lib, ...}:
let
  sandbox = import ../../../lib/sandbox-apps.nix { inherit pkgs lib; };

  sandboxedApps = sandbox.mkSandboxedApps [
    { attr = "grim"; }
    { attr = "slurp"; }
  ];
in {
  imports = [
    ./config.nix
    ./hyprpaper.nix
    ./hypridle.nix
    ./hyprlock.nix
  ];

  # config.nix generates ~/.config/hypr/hyprland.lua plus the module files
  # (00-vars.lua, 10-look-and-feel.lua, ...) via extraLuaFiles. This tree is
  # for everything else that belongs in the hypr directory: scripts/ and the
  # wallpapers. Because recursive = true links files individually, the two
  # coexist fine -- just make sure ./hypr contains no hyprland.lua,
  # hyprland.conf, or a file colliding with a module name above.
  home.file.".config/hypr" = {
    recursive = true;
    source = ./hypr;
  };

  programs.zsh.profileExtra = ''
    # Auto-start Hyprland when logging in on TTY1
    if [ -z "$DISPLAY" ] && [ "''${XDG_VTNR:-0}" -eq 1 ]; then
      exec uwsm start default
    fi
  '';

  home.packages = with pkgs; [
    # NOTE: hyprland, hyprpaper, and hypridle used to be listed here. They're
    # now provided by wayland.windowManager.hyprland.finalPackage and the
    # services.hyprpaper / services.hypridle modules. Listing them again put a
    # second, differently-versioned copy on PATH -- a classic source of
    # "why is my config not applying" after a flake update.
    wl-clipboard
    wlogout
    xdg-desktop-portal-gtk
    xdg-desktop-portal-hyprland
    gcr_4 # Provides org.gnome.keyring.SystemPrompter
  ] ++ sandboxedApps;

  # Auto-login keyring
  services.gnome-keyring.enable = true;

  # Notification Handling
  services.mako = {
    enable = true;
    settings = {
      anchor = "top-right";
      default-timeout = 5000;
      layer = "overlay";
      margin = 10;
      border-radius = 6;
    };
  };

  # Pause/Play behavior
  services.playerctld.enable = true;
}
