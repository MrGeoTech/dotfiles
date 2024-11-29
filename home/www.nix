{ config, ... }:
{
  imports = [
    ./common/core
    ./common/optional/apps/kitty
  ];

  home = {
    username = "mrgeotech";
    homeDirectory = "/home/${config.home.username}";
    stateVersion = "24.05";
  };
}
