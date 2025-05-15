{pkgs, ...}: {
  home.packages = with pkgs; [
    age
    pandoc
    bottom
  ];
}
