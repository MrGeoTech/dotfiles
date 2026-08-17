# https://github.com/sharkdp/bat
# https://github.com/eth-p/bat-extras
{pkgs, ...}: {
  programs.bat = {
    enable = true;
    config = {
      style = "numbers,changes,header";
      theme = "Catppuccin Mocha";
      # Wrap at the terminal width instead of truncating -- matters for the
      # long lines in generated Nix and lockfiles.
      wrap = "auto";
      # Use less with the right flags rather than bat's default pager string.
      pager = "less -FR";
    };
    extraPackages = builtins.attrValues {
      inherit
        (pkgs.bat-extras)
        batdiff
        batman
        batgrep
        batwatch  # re-run and re-highlight a file on change; good for logs
        prettybat
      ;
    };
  };

  home.file.".config/bat/themes" = {
    recursive = true;
    source = ./themes;
  };

  home.shellAliases = {
    man = "batman";
    cat = "bat";
    grep = "batgrep";
    diff = "batdiff";
    # Follow a log with syntax highlighting.
    tailf = "batwatch --follow";
  };

  # The alias only covers interactive `man`. MANPAGER covers everything else
  # that shells out to man: `git help`, `:Man` in nvim, `--help | man`.
  home.sessionVariables = {
    MANPAGER = "sh -c 'col -bx | bat -l man -p'";
    MANROFFOPT = "-c";
    # bat as the pager for git's own output, so `git show` gets highlighted.
    # (delta already handles diffs; this is for the rest.)
    PAGER = "less -FR";
  };
}
