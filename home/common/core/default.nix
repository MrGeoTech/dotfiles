{
  outputs,
  lib,
  pkgs,
  config,
  inputs,
  ...
}: {
  imports = [
    inputs.nix-index-database.homeModules.nix-index
    ./cli
    ./shells
    ./fonts.nix
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [
        #"gradle-7.6.6"
      ];
    };
  };

  home.packages = with pkgs; [
  ];

  # Prebuilt nixpkgs command index + `comma`, used by the
  # command-not-found handlers in ./shells to search for and sandbox-run
  # unknown commands (see home/common/lib/sandbox-apps.nix). We wire up
  # our own confirmation-gated handler instead of nix-index's default
  # "here's how you'd install it" suggestion.
  programs.nix-index-database.comma.enable = true;
  programs.nix-index.enableBashIntegration = false;
  programs.nix-index.enableZshIntegration = false;

  home.sessionVariables = {
    # Always make comma (directly, or via the command-not-found handlers)
    # ask before it builds/runs something on our behalf. comma parses this
    # as a plain Rust bool, so it must be exactly "true"/"false".
    COMMA_ASK_TO_CONFIRM = "true";
  };

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
