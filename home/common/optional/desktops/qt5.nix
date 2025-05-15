{pkgs, ...}: {
  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style = {
      package = with pkgs; (catppuccin-kvantum.override {
          accent = "mauve";
          variant = "mocha";
        });
      name = "kvantum";
    };
  };

  xdg.configFile."Kvantum/kvantum.kvconfig".source = (pkgs.formats.ini {}).generate "kvantum.kvconfig" {
    General.theme = "Catppuccin-Mocha";
  };
}
