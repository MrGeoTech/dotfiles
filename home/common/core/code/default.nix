{pkgs, ...}: {
  home.packages = with pkgs; [
    clang_18
    clang-tools
    erlang_27
    gleam
    go
    lua
    zulu
    ant
    nodejs_22
    python3
    rustc
    zig
    man-pages
    man-pages-posix
  ];
}
