{ pkgs, lib, inputs, outputs, stdenv, ... }: {
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
    # Tools
    claude-code
  ];

  # Occasional-use tools: CAD/office/media apps, compilers, IDEs, and
  # other "not part of the base system" software. Fetched on first use
  # instead of every home-manager generation carrying (and rebuilding) the
  # whole set, and run in a bwrap sandbox (see core/cli/launch.nix for the
  # `files` profile). Listing them here is the approval: no prompt.
  programs.launch.apps = {
    # note: the statistics/signal forge packages the plain package used to
    # bundle aren't included here; `pkg install -forge ...` them at runtime
    octave = { attr = "octaveFull"; bin = "octave"; profile = "files"; };
    kicad.profile = "files";
    idea = { attr = "jetbrains.idea"; profile = "files"; }; # good for java 25 development
    gradle = { attr = "gradle_9"; profile = "files"; }; # ships with its own default JDK (jdk25), no JAVA_HOME needed
    java = { attr = "openjdk25"; bin = "java"; };
    javac = { attr = "openjdk25"; bin = "javac"; };
    drawio.profile = "files";
    inkscape.profile = "files";
    libreoffice = { attr = "libreoffice-fresh"; profile = "files"; };
    vlc.access.args = "ro"; # just the file it was asked to play
    # Screen capture goes through portals and the GPU, and AppImages need
    # FUSE; neither works inside bwrap.
    obs = { attr = "obs-studio"; backend = "none"; };
    appimage-run.backend = "none";
    #quartus = { attr = "quartus-prime-lite"; };
  };

  services.mpris-proxy.enable = true;
}
