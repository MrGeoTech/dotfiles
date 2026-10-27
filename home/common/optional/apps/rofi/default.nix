{pkgs, ...}: {
  programs.rofi = {
    enable = true;
    plugins = [
      pkgs.rofi-calc
    ];
    settings = {
      font = "Iosevka Nerd Font 13";
      location = 0; # center
      terminal = "ghostty";
      # The `apps` mode (launch) is added by programs.launch, see
      # home/common/core/cli/launch.nix.
      modes = [
        "window"
        "ssh"
        "calc"
      ];
    };
    theme = "~/.config/rofi/launcher.rasi";
  };
  home.file.".config/rofi" = {
    recursive = true;
    source = ./custom;
  };
}
