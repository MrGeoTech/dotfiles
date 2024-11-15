{pkgs, ...}: {
  home.packages = with pkgs; [
    python3
    go
    nodejs_22
    rustc
    lua
  ];

  # conda
  home.file.".condarc".source = ./.condarc;
  # npm
  home.file.".npmrc".source = ./.npmrc;
}
