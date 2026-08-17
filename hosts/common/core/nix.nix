{inputs, ...}: {
  nix = {
    # Pin the `nixpkgs` flake registry entry to this flake's own nixpkgs
    # input, so `nix shell nixpkgs#...`/`comma` (used to sandbox-run
    # optional apps and unknown commands, see home/common/lib/sandbox-apps.nix)
    # resolve to the same revision the system was built from instead of
    # drifting to whatever nixpkgs-unstable happens to be at the moment.
    registry.nixpkgs.flake = inputs.nixpkgs;

    settings = {
      experimental-features = ["nix-command" "flakes"];
      auto-optimise-store = true;
      trusted-users = [ "root" "mrgeotech" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      randomizedDelaySec = "14m";
      # Keep the last 5 generations
      options = "--delete-older-than +5";
    };
  };

  # Enable nix-ld
  #programs.nix-ld.enable = true;
  # programs.nix-ld.libraries = with pkgs; [
  #   # Add any missing dynamic libraries for unpackaged programs
  #   # here, NOT in environment.systemPackages
  # ];
}
