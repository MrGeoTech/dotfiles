{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./bat
    ./direnv.nix
    ./eza.nix
    ./fastfetch.nix
    ./fzf.nix
    ./gh.nix
    ./git.nix
    ./lazygit.nix
    ./nvim
    ./ripgrep.nix
    ./yazi
    ./zoxide.nix
  ];

  home.packages = with pkgs; [
    coreutils-full
    curl
    fd # Required for fzf
    glib # MTP for USB Phone mounting
    git-extras
    gnumake
    libnotify
    libxcrypt
    ncdu
    p7zip
    pciutils
    tldr
    unrar
    unzip
    usbutils
    zip
  ];
}
