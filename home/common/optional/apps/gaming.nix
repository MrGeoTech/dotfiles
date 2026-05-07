{pkgs, inputs, ...}: {
  home.packages = with pkgs; [
    prismlauncher
    protonup-ng
  ];

  programs.mangohud.enable = true;
  home.shellAliases = {
    hytale = "flatpak run com.hypixel.HytaleLauncher";
  };
}
