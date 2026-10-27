# `launch` (~/Projects/nix-launch, flake input `nix-launch`): one ranked
# list of installed desktop apps, on-demand apps (programs.launch.apps, set
# next to where each app belongs), installed CLI tools, then all of nixpkgs.
# Nothing is installed; things are fetched on first use and run in a
# sandbox (bwrap by default). Also provides the zsh/bash command-not-found
# hook, the login indexing service, and the `apps` rofi mode (apps/rofi).
{inputs, ...}: {
  imports = [inputs.nix-launch.homeManagerModules.default];

  programs.launch = {
    enable = true;
    terminal = "ghostty";

    # The default sandbox plus the folders real work lives in, for editors
    # and CAD tools whose own file dialogs need to reach your files.
    profiles.files = {
      inherits = ["default"];
      paths = {
        "~/Projects" = "rw";
        "~/Documents" = "rw";
        "~/Downloads" = "rw";
        "~/Pictures" = "rw";
      };
    };
  };
}
