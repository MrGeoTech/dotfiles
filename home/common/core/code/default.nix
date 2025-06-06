{pkgs, ...}: {
  home.packages = with pkgs; [
    arduino-cli
    clang_18
    clang-tools
    devenv
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
