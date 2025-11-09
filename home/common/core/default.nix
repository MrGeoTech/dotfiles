{
  outputs,
  lib,
  pkgs,
  config,
  ...
}: {
  imports = [
    ./cli
    ./shells
    ./fonts.nix
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [
        #"electron-27.3.11"
      ];
    };
  };

  home.packages = with pkgs; [
  ];

  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      experimental-features = ["nix-command" "flakes"];
      warn-dirty = false;
    };
  };

  programs.home-manager.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
