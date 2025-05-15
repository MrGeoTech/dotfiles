{pkgs, ...}: {
  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "Nordzy-Cursors";
      package = pkgs.nordzy-cursor-theme;
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
  home.pointerCursor.gtk.enable = true;
  home.pointerCursor.package = pkgs.nordzy-cursor-theme;
  home.pointerCursor.name = "Nordzy-hyprcursors-white";
}
