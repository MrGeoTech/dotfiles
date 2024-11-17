{
  config,
  outputs,
  ...
}: {
  imports = [
    ./common/core
    ./common/optional/desktops/hyprland
    ./common/optional/apps/linux-only.nix
    ./common/optional/apps/kitty
    ./common/optional/apps/rofi
    ./common/optional/desktops/waybar
    ./common/optional/desktops/gtk.nix
    ./common/optional/desktops/qt5.nix
    ./common/optional/desktops/xdg.nix
  ];

  home = {
    username = "mrgeotech";
    homeDirectory = "/home/${config.home.username}";
    stateVersion = "23.11";
  };
}
