{
  pkgs,
  config,
  outputs,
  ...
}: {
  imports = [
    ./common/core
    ./common/optional/apps/ghostty
    ./common/optional/apps/rofi
    ./common/optional/apps/vivaldi.nix
    ./common/optional/apps/gpg.nix
    ./common/optional/desktops/hyprland
    ./common/optional/desktops/waybar
    ./common/optional/desktops/gtk.nix
    ./common/optional/desktops/qt5.nix
    ./common/optional/desktops/xdg.nix
  ];

  home = {
    username = "mrgeotech";
    homeDirectory = "/home/${config.home.username}";
    stateVersion = "24.11";
    packages = with pkgs; [
      protonup
    ];
 
    sessionVariables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\\\${HOME}/.steam/root/compatibilitytools.d";
    };
  };
}
