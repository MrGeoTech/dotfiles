{pkgs, ...}: {
  home.packages = with pkgs; [
    age
    bottom
  ];
}
