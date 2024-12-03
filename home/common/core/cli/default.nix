{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
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
    ./scripts.nix
    ./yazi
    ./zoxide.nix
  ];

  home.packages = with pkgs; [
    bc
    coreutils-full
    curl
    entr
    fd
    git-extras
    gnumake
    libnotify
    libxcrypt
    ncdu
    nix-tree
    p7zip
    pciutils
    procs
    thefuck
    tldr
    unrar
    unzip
    usbutils
    zip
  ];
}
