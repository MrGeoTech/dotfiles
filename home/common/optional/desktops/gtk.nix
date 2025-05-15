{pkgs, ...}: {
  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "Bibata-Original-Ice";
      package = pkgs.bibata-cursors;
    };
    theme = {
      name = "Nordic";
      package = pkgs.nordic;
    };
    gtk3.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };

    gtk4.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };
  };

  home.sessionVariables.GTK_THEME = "Nordic";
  home.pointerCursor = {
    gtk.enable = true;
    hyprcursor.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Original-Ice";
    size = 24;
  };
}
