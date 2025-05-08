{ config, pkgs, lib, ... }:
let
  catppuccinOhMyZsh = ''
    PROMPT='%F{green}%t%f %F{yellow}%~%f %F{white}>%f '
    RPS1='%F$(git_prompt_info) %{$fg_bold[blue]%}%m%{$reset_color%}'
    
    ZSH_THEME_GIT_PROMPT_PREFIX=" %{$fg[yellow]%}("
    ZSH_THEME_GIT_PROMPT_SUFFIX=")%{$reset_color%}"
    ZSH_THEME_GIT_PROMPT_CLEAN=""
    ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%} ⚡%{$fg[yellow]%}"
  '';
in
{
  # write my theme file
  home.file.".config/oh-my-zsh/custom/themes/catppuccin.zsh-theme".text = catppuccinOhMyZsh;

  programs.zsh = {
    enable = true;
    enableCompletion = true;

    autocd = true;
    history.extended = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    initContent = ''
      bindkey '^ ' autosuggest-accept
    '';

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "thefuck" ];
      custom = "$HOME/.config/oh-my-zsh/custom";
      theme = "catppuccin";
    };
  };
}
