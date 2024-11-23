{ pkgs, inputs, ... }:
{
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
        drawio
        eog
        octaveFull
        quartus-prime-lite
        resources
        signal-desktop
        zoom-us
    ];

    home.sessionVariables = {
        LM_LICENSE_FILE = "/home/mrgeotech/.secrets/License.dat";
    };
}
