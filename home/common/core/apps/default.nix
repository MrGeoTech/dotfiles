{pkgs, ...}: {
  imports = [
    ./zathura
  ];

  home.packages = with pkgs; [
    age
    pandoc
    texliveFull
    zoom-us
  ];
}
