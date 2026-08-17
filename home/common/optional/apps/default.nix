{ pkgs, lib, inputs, outputs, stdenv, ... }:
let
  sandbox = import ../../lib/sandbox-apps.nix { inherit pkgs lib; };

  # Occasional-use tools: CAD/office/media apps, compilers, IDEs, and
  # other "not part of the base system" software. Wrapped so `nix shell`
  # fetches/builds them on first use instead of every home-manager
  # generation carrying (and rebuilding) the whole set.
  sandboxedApps = sandbox.mkSandboxedApps [
    { attr = "octaveFull"; bin = "octave"; } # note: the statistics/signal forge packages the plain package used to bundle aren't included here; `pkg install -forge ...` them at runtime if needed
    { attr = "kicad"; }
    { attr = "jetbrains.idea"; bin = "idea"; } # good for java 25 development
    { attr = "gradle_9"; bin = "gradle"; } # ships with its own default JDK (jdk25), no JAVA_HOME needed
    { attr = "openjdk25"; bin = "java"; }
    { attr = "openjdk25"; bin = "javac"; }
    { attr = "drawio"; }
    { attr = "inkscape"; }
    { attr = "obs-studio"; bin = "obs"; }
    { attr = "vlc"; }
    { attr = "appimage-run"; }
    { attr = "libreoffice-fresh"; bin = "libreoffice"; }
    #{ attr = "quartus-prime-lite"; }
  ];
in
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
        libgcc
        udisks
        flatpak
        # User apps kept installed: daily drivers, not occasional tools
        google-chrome # Needed to take certain tests
        signal-desktop
    ] ++ sandboxedApps;

    services.mpris-proxy.enable = true;
}
