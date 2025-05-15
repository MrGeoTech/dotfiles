{ pkgs, ... }: {
    environment.systemPackages = with pkgs; [
        (sddm-astronaut.override {
          embeddedTheme = "purple_leaves";
        })
    ];
    services.displayManager.sddm = {
        enable = true;
        wayland.enable = true;
        autoNumlock = true;

        theme = "sddm-astronaut-theme";
        package = pkgs.kdePackages.sddm;
        extraPackages = with pkgs; [
          kdePackages.qtsvg
          kdePackages.qtmultimedia
        ];
    };
}
