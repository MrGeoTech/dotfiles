{ inputs, hostName, ... }:
{
  programs.ghostty = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    settings = {
      font-family = "IosevkaTerm";
      font-size = if hostName == "mrgeotech-zenbook" then "18" else "12";
      background-opacity = 0.85;
      background = "1e1e2e";
      theme = "catppuccin-mocha";
    };
  };
}
