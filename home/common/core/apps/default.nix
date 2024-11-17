{pkgs, ...}: {
  imports = [
    ./zathura
  ];

  home.packages = with pkgs; [
    age
    pandoc
    bottom
  ];
}
