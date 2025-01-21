{
    xdg.enable = true;

    xdg.desktopEntries = {
        okular = {
            name = "Okular";
            genericName = "PDF Viewer";
            exec = "okular %U";
            terminal = false;
            categories = ["Application"];
            mimeType = ["application/pdf"];
        };
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
            "application/pdf" = ["okular.desktop"];
            "text/html" = ["firefox-browser.desktop"];
            "application/xhtml+xml" = ["firefox-browser.desktop"];
            "x-scheme-handler/http" = ["firefox-browser.desktop"];
            "x-scheme-handler/https" = ["firefox-browser.desktop"];
            "inode/directory" = ["yazi.desktop"];
        };
    };
}
