# https://github.com/eza-community/eza
#
# You had eza enabled but no shell integration, so `ls` was still coreutils --
# the package was installed and unused. enableZshIntegration wires up
# ls/ll/la/lt; the rest are additions.
{
  programs.eza = {
    enable = true;
    git = true;
    icons = "auto";
    enableZshIntegration = true;
    enableBashIntegration = true;
    extraOptions = [
      "--group-directories-first"
      "--header"
      "--hyperlink"        # Ghostty makes filenames clickable / ctrl-clickable
      "--time-style=long-iso"
    ];
  };

  home.shellAliases = {
    # Tree views at useful depths -- `lt` alone is usually too deep to read.
    lt = "eza --tree --level=2";
    lt3 = "eza --tree --level=3";
    ltg = "eza --tree --level=3 --git-ignore";

    # Sorted views for "what did I just touch" and "what's eating this dir".
    lm = "eza -l --sort=modified --reverse";
    lsize = "eza -l --sort=size --reverse --total-size";

    # Full detail incl. git status, permissions in octal.
    ll = "eza -l --git --octal-permissions";
    la = "eza -la --git";
  };
}
