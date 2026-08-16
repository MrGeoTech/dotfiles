# https://github.com/hyprwm/Hyprland
{pkgs, ...}: {
  imports = [
    ./config.nix
    ./hyprpaper.nix
    ./hypridle.nix
    ./hyprlock.nix
  ];

  # NOTE: config.nix now writes .config/hypr/hyprland.lua itself (Hyprland
  # 0.55+ uses Lua instead of hyprland.conf). Make sure your ./hypr source
  # directory below does NOT contain a hyprland.conf or hyprland.lua of its
  # own, or home-manager will complain about two things managing the same
  # path. It's fine for ./hypr to still contain scripts/, mocha.conf (unused
  # now, safe to delete or keep for reference), etc.
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
    grim
    hyprland
    hyprpaper
    hypridle
    hdrop
    libinput
    networkmanagerapplet
    pavucontrol
    pipewire
    slurp
    swayidle
    swaylock-effects
    wl-clipboard
    wlogout
    xdg-desktop-portal-gtk
    xdg-desktop-portal-hyprland
    gcr # Provides org.gnome.keyring.SystemPrompter
  ];

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
