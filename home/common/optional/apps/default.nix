{ pkgs, inputs, ... }:
{
    imports = [
        ./ghostty
        ./rofi
        ./gpg.nix
        ./gaming.nix
        #./firefox.nix
        ./vivaldi.nix
    ];
    home.packages = with pkgs; [
        # System utilities
        appimage-run
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
        android-studio
        drawio
        eog
        google-chrome
        inkscape
        kicad
        obs-studio
        octaveFull
        octavePackages.statistics
        quartus-prime-lite
        resources
        signal-desktop
        vlc
    ];

    services.mpris-proxy.enable = true;

    home.sessionVariables = {
        LM_LICENSE_FILE = "/home/mrgeotech/.secrets/License.dat";
    };

    home.shellAliases = {
        vlcav = "VDPAU_TRACE=1 vlc";
    };
}
