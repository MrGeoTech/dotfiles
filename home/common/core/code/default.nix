{pkgs, ...}: {
  home.packages = with pkgs; [
    clang_18
    go
    lua
    nodejs_22
    python3
    rustc
    zig
  ];
}
