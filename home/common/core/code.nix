{pkgs, ...}: {
  home.packages = with pkgs; [
    devenv
    man-pages
    man-pages-posix
  ];
}
