{pkgs, ...}: {
  home.packages = with pkgs; [
    clang_18
    clang-tools
    go
    lua
    nodejs_22
    python3
    rustc
    zig
  ];
}
