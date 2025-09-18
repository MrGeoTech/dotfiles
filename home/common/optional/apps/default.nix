{ pkgs, inputs, ... }:
{
    imports = [
        ./ghostty
        ./rofi
        ./gpg.nix
        ./gaming.nix
        #./firefox.nix # Needed for streaming platforms (looking at you peacock)
        ./vivaldi.nix
    ];
    home.packages = with pkgs; [
        # System utilities
        appimage-run
        libgcc
        libreoffice-fresh
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
