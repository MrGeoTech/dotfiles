{pkgs, ...} : let
  editorDesktopFile = pkgs.writeTextFile {
    name = "nvim.desktop";
    destination = "/share/applications/nvim.desktop";
    text = ''
      [Desktop Entry]
      Name=Neovim
      Comment=Edit text files in the terminal using Neovim
      Exec=${pkgs.ghostty}/bin/ghostty -- nvim %F
      Type=Application
      Terminal=true
      MimeType=text/plain;text/markdown;text/x-shellscript;text/x-csrc;text/x-c++src;text/x-python;application/json;application/x-yaml;
      Categories=Utility;TextEditor;
      StartupNotify=false
    '';
  };

  editorDesktop = "nvim.desktop";
  browserDesktop = "vivaldi-stable.desktop";
  fileManagerDesktop = "yazi.desktop";
in {
  xdg.enable = true;

  xdg.desktopEntries = {
    yazi = {
      name = "Yazi";
      genericName = "File Manager";
      exec = "ghostty -e yazi %U";
      terminal = false;
      categories = ["Application"];
      mimeType = ["inode/directory"];
    };
  };

  xdg.dataFile."applications/nvim.desktop".source = editorDesktopFile;

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # Browser-related
      "text/html" = [ browserDesktop ];
      "application/xhtml+xml" = [ browserDesktop ];
      "application/xml" = [ browserDesktop ];
      "application/pdf" = [ browserDesktop ];
      "x-scheme-handler/http" = [ browserDesktop ];
      "x-scheme-handler/https" = [ browserDesktop ];
      "x-scheme-handler/ftp" = [ browserDesktop ];

      # Directories
      "inode/directory" = [ fileManagerDesktop ];

      # Text and code files
      "text/plain" = [ editorDesktop ];
      "text/markdown" = [ editorDesktop ];
      "text/x-shellscript" = [ editorDesktop ];
      "application/json" = [ editorDesktop ];
      "application/x-yaml" = [ editorDesktop ];
      "application/javascript" = [ editorDesktop ];
      "text/x-python" = [ editorDesktop ];
      "text/x-csrc" = [ editorDesktop ];
      "text/x-c++src" = [ editorDesktop ];
      "text/x-rustsrc" = [ editorDesktop ];

      # Office documents
      "application/msword" = [ "libreoffice-writer.desktop" ];
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = [ "libreoffice-writer.desktop" ];
      "application/vnd.ms-excel" = [ "libreoffice-calc.desktop" ];
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = [ "libreoffice-calc.desktop" ];
      "application/vnd.ms-powerpoint" = [ "libreoffice-impress.desktop" ];
      "application/vnd.openxmlformats-officedocument.presentationml.presentation" = [ "libreoffice-impress.desktop" ];
      "application/vnd.oasis.opendocument.text" = [ "libreoffice-writer.desktop" ];
      "application/vnd.oasis.opendocument.spreadsheet" = [ "libreoffice-calc.desktop" ];
      "application/vnd.oasis.opendocument.presentation" = [ "libreoffice-impress.desktop" ];

      # Images
      "image/svg+xml" = [ browserDesktop ];
      "image/png" = [ browserDesktop ];
      "image/jpeg" = [ browserDesktop  ];
      "image/webp" = [ browserDesktop  ];
    };
  };
}
