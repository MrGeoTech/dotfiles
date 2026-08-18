{pkgs, inputs, ...}: {
  programs.mangohud.enable = true;
  home.shellAliases = {
    hytale = "flatpak run com.hypixel.HytaleLauncher";
  };
}
