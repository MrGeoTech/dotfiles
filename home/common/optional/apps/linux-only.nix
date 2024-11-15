{pkgs, ...}: {
  imports = [
    ./gpg.nix
    ./firefox.nix
  ];
  home.packages = with pkgs; [
    appimage-run
    eog
    gparted
    libgcc
    libreoffice-fresh
    libsForQt5.okular
    lshw
    obsidian
    resources
    psmisc
    seahorse
    signal-desktop
    udisks
  ];
}
