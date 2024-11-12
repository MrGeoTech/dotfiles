{pkgs, ...}: {
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    font = "Iosevka NF";
    location = "center";
    terminal = "alacritty";
    plugins = [
      pkgs.rofi-calc
    ];
    theme = "~/.config/rofi/launcher.rasi";
  };
  home.file.".config/rofi" = {
    recursive = true;
    source = ./custom;
  };
}
