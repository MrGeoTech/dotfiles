{pkgs, ...}: {
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    nerd-fonts.iosevka-term
    nerd-fonts.iosevka
    cascadia-code
    font-awesome
    #noto-fonts
    #noto-fonts-emoji
    #recursive
    #sn-pro
    #ia-writer-quattro
    #ia-writer-duospace
    #libre-baskerville
    #monaspace
  ];
}
