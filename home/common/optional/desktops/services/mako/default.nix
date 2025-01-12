# https://github.com/emersion/mako
{
  services.mako = {
    enable = true;
    anchor = "top-right";
    borderRadius = 2;
    borderSize = 2;
    font = "Iosevka";
    icons = true;
    extraConfig = builtins.readFile ./config;
  };
}
