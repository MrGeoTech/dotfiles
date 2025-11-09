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
    ./yazi
    ./zoxide.nix
  ];

  home.packages = with pkgs; [
    coreutils-full
    curl
    fd # Required for fzf
    glib # MTP for USB Phone mounting
    gnumake
    libnotify
    libxcrypt
    ncdu
    pciutils
    usbutils

    age
    bottom

    man-pages
    man-pages-posix
  ];
}
