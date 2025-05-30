# https://github.com/sharkdp/bat
# https://github.com/eth-p/bat-extras
{pkgs, ...}: {
  programs.bat = {
    enable = true;
    config = {
      # Show line numbers, Git modifications and file header (but no grid)
      style = "numbers,changes,header";
      theme = "Catppuccin Mocha";
    };
    extraPackages = builtins.attrValues {
      inherit
        (pkgs.bat-extras)
        batgrep # search through and highlight files using ripgrep
        batdiff # Diff a file against the current git index, or display the diff between to files
        batman # man pages with syntax highlighting
        ;
    };
  };

  # copy themes
  home.file.".config/bat/themes" = {
    recursive = true;
    source = ./themes;
  };

  # aliases
  home.shellAliases = {
    man = "batman";
    cat = "bat";
    grep = "batgrep";
    diff = "batdiff";
  };
}
