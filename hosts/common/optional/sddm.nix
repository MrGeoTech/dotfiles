{ pkgs, ... }: {
    environment.systemPackages = [
        (pkgs.catppuccin-sddm.override {
            flavor = "mocha";
            font  = "Iosevka";
            fontSize = "18";
            background = "${../../../home/common/optional/desktops/hyprland/hypr/tropic_island_night.jpg}";
            loginBackground = true;
        })
    ];
    services.displayManager.sddm = {
        enable = true;
        wayland.enable = true;
        autoNumlock = true;

        theme = "catppuccin-mocha";
        package = pkgs.kdePackages.sddm;
    };
}
