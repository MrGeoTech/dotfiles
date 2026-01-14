{pkgs, inputs, ...}: {
    home.packages = with pkgs; [
        prismlauncher
        protonup-ng
    ];

    home.shellAliases = {
      hytale = "flatpak run com.hypixel.HytaleLauncher";
    };
}
