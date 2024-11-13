{
  outputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./apps
    ./cli
    ./code
    ./fonts.nix
    ./shells
  ];

  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    config.allowUnfree = true;
  };

  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      experimental-features = ["nix-command" "flakes"];
      warn-dirty = false;
    };
  };

  programs.home-manager.enable = true;

  #home.file."Downloads/" = lib.file.mkOutOfStoreSymlink /shared/Downloads;
  #home.file.".config/fsh/catppuccin-mocha.ini".source = ./catppuccin-mocha.ini;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
