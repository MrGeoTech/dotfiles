# https://cli.github.com/
{pkgs, ...}: {
  programs.gh = {
    enable = true;
    extensions = with pkgs; [gh-markdown-preview];
    settings = {
      git_protocol = "ssh";
    };
  };
  programs.gh-dash = {
    enable = true;
  };
}
