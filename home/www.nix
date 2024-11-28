{ config, ... }:
{
  imports = [
    ./common/core
  ];

  home = {
    username = "mrgeotech";
    homeDirectory = "/home/${config.home.username}";
    stateVersion = "24.05";
  };
}
