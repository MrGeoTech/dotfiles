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
    ./fzf.nix
    ./gh.nix
    ./git.nix
    ./lazygit.nix
    ./nvim
    ./ripgrep.nix
    ./scripts.nix
    ./oh-my-posh
    ./tmux
    ./yazi
    ./zoxide.nix
  ];

  home.packages = with pkgs; [
    bc
    bottom
    coreutils-full
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
    tldr
    unrar
    unzip
    curl
    zip
  ];
}
