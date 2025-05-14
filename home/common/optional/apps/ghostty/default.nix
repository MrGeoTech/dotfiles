{ inputs, hostName, ... }:
{
  home.packages = [
    inputs.ghostty.packages.x86_64-linux.default
  ];

  home.file.".config/ghostty/config" = {
    text = ''
      font-size = ${
        if hostName == "mrgeotech-zenbook" then "18" else "12"
      }
      font-family = "IosevkaTerm"
      background-opacity = 0.85
      theme = catppuccin-mocha
    '';
  };
}
