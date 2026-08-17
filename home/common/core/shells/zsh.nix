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
  home.file.".config/oh-my-zsh/custom/themes/catppuccin.zsh-theme".text = catppuccinOhMyZsh;

  programs.zsh = {
    enable = true;
    enableCompletion = true;

    dotDir = "${config.xdg.configHome}/zsh";
    autocd = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      extended = true;
      size = 100000;
      save = 100000;
      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;      # leading space keeps a command out of history
      expireDuplicatesFirst = true;
      share = true;
    };

    # fzf-tab turns every completion menu into an fzf picker with a preview.
    # ORDERING MATTERS: it must load after compinit and before the widget
    # wrappers (autosuggestions / syntax-highlighting). If Tab still gives you
    # the plain zsh menu, that's the symptom -- move this to an explicit
    # `source` inside initContent with lib.mkOrder 550.
    plugins = [
      {
        name = "fzf-tab";
        src = pkgs.zsh-fzf-tab;
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
      }
    ];

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "sudo"           # press Esc twice to prefix the last command with sudo
        "extract"        # `x <anything>` unpacks it
        "command-not-found"
      ];
      custom = "${config.xdg.configHome}/oh-my-zsh/custom";
      theme = "catppuccin";
    };

    initContent = lib.mkMerge [
      (lib.mkOrder 1000 ''
        bindkey '^ ' autosuggest-accept
      '')

      (lib.mkAfter ''
        # --- vi mode, but only the parts that pull their weight ------------
        # Edit the current command line in nvim with `v` in normal mode, or
        # Ctrl-X Ctrl-E anywhere. Indispensable for multi-line commands.
        autoload -Uz edit-command-line
        zle -N edit-command-line
        bindkey '^x^e' edit-command-line

        # --- fzf-tab styling ----------------------------------------------
        # Disable zsh's own menu so fzf-tab owns the interaction.
        zstyle ':completion:*' menu no
        zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
        zstyle ':fzf-tab:*' use-fzf-default-opts yes
        zstyle ':fzf-tab:*' switch-group '<' '>'
        zstyle ':fzf-tab:*' fzf-min-height 20

        # Directory completions preview their contents.
        zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --icons --color=always $realpath'
        zstyle ':fzf-tab:complete:z:*'  fzf-preview 'eza -1 --icons --color=always $realpath'
        zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --icons --color=always $realpath'

        # File arguments preview with bat.
        zstyle ':fzf-tab:complete:(nvim|bat|cat|less|rm|cp|mv):argument-rest' \
          fzf-preview 'bat --color=always --line-range :200 $realpath 2>/dev/null || eza -1 --icons --color=always $realpath'

        # systemctl completions show unit status.
        zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'

        # Environment variables show their value.
        zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' \
          fzf-preview 'echo ''${(P)word}'

        # git subcommands get a real preview instead of a bare list.
        zstyle ':fzf-tab:complete:git-(add|diff|restore):*' \
          fzf-preview 'git diff --color=always $word | delta'
        zstyle ':fzf-tab:complete:git-checkout:*' \
          fzf-preview 'git log --color=always --oneline --graph -20 $word'

        # --- small quality-of-life ----------------------------------------
        setopt AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT
        setopt INTERACTIVE_COMMENTS   # allow # comments when pasting commands
        setopt GLOB_DOTS              # let * match dotfiles
        setopt NO_BEEP

        # `..` `...` `....` to walk up. autocd makes these work as commands.
        alias ..='cd ..'
        alias ...='cd ../..'
        alias ....='cd ../../..'

        # `-` alone goes to the previous directory.
        alias -- -='cd -'

        # mkdir and cd in one move.
        mkcd() { mkdir -p "$1" && cd "$1"; }

        # Ctrl-o inside a shell drops into yazi; quitting returns you to the
        # directory yazi was in. The mirror of `y`.
        yazi-cd() { y; zle reset-prompt; }
        zle -N yazi-cd
        bindkey '^o' yazi-cd
      '')
    ];
  };
}
