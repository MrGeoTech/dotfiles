{
    xdg.enable = true;

    xdg.desktopEntries = {
        yazi = {
            name = "Yazi";
            genericName = "File Manager";
            exec = "kitty -e yazi %U";
            terminal = false;
            categories = ["Application"];
            mimeType = ["inode/directory"];
        };
    };

    xdg.mimeApps = {
        enable = true;
        defaultApplications = {
            "application/pdf" = ["vivaldi-stable.desktop"];
            "text/html" = ["vivaldi-stable.desktop"];
            "application/xhtml+xml" = ["vivaldi-stable.desktop"];
            "x-scheme-handler/http" = ["vivaldi-stable.desktop"];
            "x-scheme-handler/https" = ["vivaldi-stable.desktop"];
            "inode/directory" = ["yazi.desktop"];
        };
    };
}
