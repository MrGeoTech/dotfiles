# You can build these directly using 'nix build .#example'
{pkgs ? import <nixpkgs> {}}: rec {
  #################### Packages with external source ####################

  # example = pkgs.callPackage ./example {};
  # winapps-helper = pkgs.callPackage ./winapps-helper {};
  xilinx-tools = pkgs.callPackage ./xilinx-tools {};
}
