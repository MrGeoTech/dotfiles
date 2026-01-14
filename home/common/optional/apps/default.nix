{ pkgs, inputs, outputs, stdenv, ... }:
{
    imports = [
        ./ghostty
        ./rofi
        ./gpg.nix
        ./gaming.nix
        ./vivaldi.nix
        ./labrador.nix
    ];
    home.packages = with pkgs; [
        # System utilities
        appimage-run
        libgcc
        libreoffice-fresh
        udisks
        flatpak
        # User Apps
        drawio
        google-chrome # Needed to take certain tests
        inkscape
        kicad
        obs-studio
        octaveFull
        jetbrains.idea # Good for java 25 development
        gradle_9
        openjdk25
        #quartus-prime-lite
        signal-desktop
        vlc
    ];

    services.mpris-proxy.enable = true;

    home.sessionVariables = {
        LM_LICENSE_FILE = "/home/mrgeotech/.secrets/License.dat";
        JAVA_HOME = "${pkgs.openjdk25}/lib/openjdk";
    };

    home.shellAliases = {
        vlcav = "VDPAU_TRACE=1 vlc";
    };
}
