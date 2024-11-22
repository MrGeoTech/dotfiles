{pkgs, ...}: {
  home.packages = with pkgs; [
    clang_18
    clang-tools
    erlang_27
    go
    lua
    nodejs_22
    python3
    rustc
    zig
  ];
}
