{
  config,
  outputs,
  ...
}: {
  imports = [
    ./common/core
    ./common/optional/apps
    ./common/optional/desktops/hyprland
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
