{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: 
let
  sandbox = import ../../lib/sandbox-apps.nix { inherit pkgs lib; };

  sandboxedApps = sandbox.mkSandboxedApps [
    { attr = "grim"; }
    { attr = "slurp"; }
    { attr = "ncdu"; }
    { attr = "pciutils"; }
    { attr = "usbutils"; }
    { attr = "bottom"; }
    { attr = "man-pages"; }
    { attr = "man-pages-posix"; }
  ];
in {
  imports = [
    ./atuin.nix
    ./bat
    ./delta
    ./direnv.nix
    ./eza.nix
    ./fastfetch.nix
    ./fzf.nix
    ./gh.nix
    ./git.nix
    ./lazygit.nix
    ./nvim
    ./ripgrep.nix
    ./ssh.nix
    ./yazi
    ./zoxide.nix
  ];

  home.packages = with pkgs; [
    age # used directly (not via nix shell) by ~/.config/nvim's .priv/.me encryption, see nvim/lua/crypt.lua
    coreutils-full
    curl
    fd # Required for fzf
    glib # MTP for USB Phone mounting
    gnumake
    libnotify
    libxcrypt
  ] ++ sandboxedApps;
}
