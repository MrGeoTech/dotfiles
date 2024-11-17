{pkgs, ...}: {
  imports = [
    ./gpg.nix
    ./firefox.nix
  ];
  home.packages = with pkgs; [
    # System utilities
    appimage-run
    gparted
    libgcc
    libreoffice-fresh
    libsForQt5.okular
    lshw
    psmisc
    seahorse
    udisks
    # Programming Stuff
    texliveFull
    # User Apps
    eog
    octaveFull
    quartus-prime-lite
    resources
    signal-desktop
    zoom-us
  ];

  home.sessionVariables = {
    OBSIDIAN_USE_WAYLAND = "1";
  };
}
