# https://github.com/hyprwm/Hyprland
{pkgs, ...}: {
  imports = [
    ./config.nix
    ./hyprpaper.nix
    ./hypridle.nix
    ./hyprlock.nix
  ];
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
}
