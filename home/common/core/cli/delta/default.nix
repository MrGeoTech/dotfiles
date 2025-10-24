# Required for LazyGit
{
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      features = "line-numbers decorations catppuccin-mocha";
    };
  };
  # copy themes
  home.file.".config/delta/themes" = {
    recursive = true;
    source = ./themes;
  };
  # include theme
  programs.git.includes = [
    {path = "~/.config/delta/themes/catppuccin.gitconfig";}
  ];
}
