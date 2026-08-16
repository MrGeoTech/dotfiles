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
        (octaveFull.withPackages(opkgs: with opkgs; [
          statistics
          signal
        ]))
        jetbrains.idea # Good for java 25 development
        gradle_9
        openjdk25
        #quartus-prime-lite
        signal-desktop
        vlc
    ];

    services.mpris-proxy.enable = true;

    home.sessionVariables = {
        JAVA_HOME = "${pkgs.openjdk25}/lib/openjdk";
    };
}
