{
  outputs,
  lib,
  pkgs,
  config,
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
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [
        #"electron-27.3.11"
      ];
    };
  };

  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      experimental-features = ["nix-command" "flakes"];
      warn-dirty = false;
    };
  };

  programs.home-manager.enable = true;

  home.file."Desktop".source = config.lib.file.mkOutOfStoreSymlink /shared/Desktop;
  home.file."Downloads".source = config.lib.file.mkOutOfStoreSymlink /shared/Downloads;
  home.file."Documents".source = config.lib.file.mkOutOfStoreSymlink /shared/Documents;
  home.file."Pictures".source = config.lib.file.mkOutOfStoreSymlink /shared/Pictures;
  home.file."Projects".source = config.lib.file.mkOutOfStoreSymlink /shared/Projects;
  home.file."School".source = config.lib.file.mkOutOfStoreSymlink /shared/School;
  home.file."Videos".source = config.lib.file.mkOutOfStoreSymlink /shared/Videos;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
