{pkgs, ...}: {
  imports = [
    ./gpg.nix
  ];
  home.packages = with pkgs; [
    appimage-run
    firefox
    eog
    gparted
    libgcc
    libreoffice-fresh
    libsForQt5.okular
    lshw
    nautilus
    obsidian
    psmisc
    seahorse
    signal-desktop
    udisks
  ];
}
