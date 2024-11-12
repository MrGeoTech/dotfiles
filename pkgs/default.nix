# You can build these directly using 'nix build .#example'
{pkgs ? import <nixpkgs> {} }: rec {
  #################### Packages with external source ####################

  #oh-my-zsh-catppuccin = pkgs.callPackage ./oh-my-zsh-catppuccin {};
}
