{pkgs, outputs, ...}: {
  home.packages = with pkgs; [
    arduino-cli
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
  ];# ++ [ outputs.myPkgs.${pkgs.system}.xilinx-tools ];
}
