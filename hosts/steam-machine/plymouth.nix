{ config, pkgs, ... }:
{
  boot.plymouth = {
    enable = true;
    theme = "loader_alt";
    themePackages = [ pkgs.adi1090x-plymouth-themes ];
  };
}
