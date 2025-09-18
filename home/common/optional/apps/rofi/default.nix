{pkgs, ...}: {
  programs.rofi = {
    enable = true;
    font = "Iosevka";
    location = "center";
    terminal = "ghostty";
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
