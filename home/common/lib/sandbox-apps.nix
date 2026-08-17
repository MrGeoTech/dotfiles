# Helpers for keeping the "base system" (browser, file manager, desktop,
# terminal, editor) fully configured and always installed, while letting
# occasional-use tools (compilers, CAD/office apps, media players, etc.)
# get fetched and run on demand through `nix shell` instead of living in
# every home-manager generation.
{
  lib,
  pkgs,
}: let
  mkSandboxedApp = {
    # Dot-separated nixpkgs attribute path, e.g. "jetbrains.idea".
    attr,
    # Executable to run inside the shell. Defaults to the package's
    # `meta.mainProgram`, falling back to the last segment of `attr`.
    bin ? null,
    # Name of the wrapper script put on PATH. Defaults to `bin`.
    name ? null,
  }: let
    pkg =
      lib.attrByPath (lib.splitString "." attr)
      (throw "sandbox-apps: unknown nixpkgs attribute `${attr}`")
      pkgs;
    binName =
      if bin != null
      then bin
      else pkg.meta.mainProgram or (lib.last (lib.splitString "." attr));
    wrapperName =
      if name != null
      then name
      else binName;
  in
    pkgs.writeShellScriptBin wrapperName ''
      set -eu
      exec nix shell "nixpkgs#${attr}" --command ${lib.escapeShellArg binName} "$@"
    '';
in {
  inherit mkSandboxedApp;
  mkSandboxedApps = builtins.map mkSandboxedApp;
}
