{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
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
    ./launch.nix
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
    # Plain documentation, so `man 2 open` / `man 3p printf` work. These
    # used to be on-demand wrappers, but they ship no program to run.
    man-pages
    man-pages-posix
  ];

  # Fetched on first use (see ./launch.nix). System inspection tools run
  # unsandboxed: they exist to look at the real /proc, /sys and disks.
  programs.launch.apps = {
    ncdu.backend = "none";
    lspci = { attr = "pciutils"; backend = "none"; };
    lsusb = { attr = "usbutils"; backend = "none"; };
    btm = { attr = "bottom"; backend = "none"; };
  };
}
