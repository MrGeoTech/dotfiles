# https://github.com/junegunn/fzf
#
# Ctrl-R is atuin's: both fzf and atuin bind it by default, and atuin's init
# (see cli/atuin.nix) sources after fzf's, so fzf's binding is disabled below
# to avoid the conflict rather than relying on source order.
{ pkgs, ... }: {
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;

    # fd instead of find: respects .gitignore, skips .git, much faster.
    # `fd` is already in your cli/default.nix package list.
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    defaultOptions = [
      "--height 60%"
      "--layout=reverse"
      "--border=rounded"
      "--info=inline"
      "--marker=' '"
      "--pointer='▶'"
      "--prompt='  '"
      "--cycle"
      # Vim keys for the preview pane, since fzf's defaults are arrow-only.
      "--bind=ctrl-/:toggle-preview"
      "--bind=ctrl-d:preview-half-page-down"
      "--bind=ctrl-u:preview-half-page-up"
      "--bind='ctrl-y:execute-silent(echo {} | wl-copy)'"
      "--bind=alt-j:down,alt-k:up"
    ];

    # Ctrl-T: paste a file path onto the command line, with a bat preview.
    fileWidget = {
      command = "fd --type f --hidden --follow --exclude .git";
      options = [
        "--preview 'bat --style=numbers --color=always --line-range :300 {}'"
        "--preview-window=right:60%:wrap"
      ];
    };

    # Alt-C: cd into a directory, previewing its tree.
    changeDirWidget = {
      command = "fd --type d --hidden --follow --exclude .git";
      options = [
        "--preview 'eza --tree --level=2 --icons --color=always {}'"
      ];
    };

    # Ctrl-R: leave it to atuin (see cli/atuin.nix), which owns it after
    # fzf's shell init sources.
    historyWidget.command = "";

    # Catppuccin Mocha, matching bat/yazi/hyprland.
    colors = {
      "bg+" = "#313244";
      "bg" = "#1e1e2e";
      "spinner" = "#f5e0dc";
      "hl" = "#f38ba8";
      "fg" = "#cdd6f4";
      "header" = "#f38ba8";
      "info" = "#cba6f7";
      "pointer" = "#f5e0dc";
      "marker" = "#b4befe";
      "fg+" = "#cdd6f4";
      "prompt" = "#cba6f7";
      "hl+" = "#f38ba8";
      "selected-bg" = "#45475a";
    };
  };

  # Small fzf-powered functions. Each one replaces a thing you'd otherwise do
  # with several commands and a copy-paste.
  programs.zsh.initContent = ''
    # fkill -- pick a process, kill it. Preview shows the full command line.
    fkill() {
      local pid
      pid=$(ps -eo pid,pcpu,pmem,comm --sort=-pcpu --no-headers \
        | fzf --header='PID   %CPU  %MEM  COMMAND' \
              --preview 'ps -p {1} -o pid,ppid,user,etime,args --no-headers' \
              --preview-window=down:4:wrap \
        | awk '{print $1}')
      [[ -n "$pid" ]] && kill "''${1:--TERM}" "$pid"
    }

    # frg -- ripgrep the tree, live, and open the hit in nvim at the right line.
    frg() {
      local out file line
      out=$(rg --line-number --no-heading --color=always --smart-case "''${*:-}" \
        | fzf --ansi --delimiter=: \
              --preview 'bat --color=always --highlight-line {2} --line-range $(({2}>10 ? {2}-10 : 1)): {1}' \
              --preview-window=right:60%:wrap)
      [[ -z "$out" ]] && return
      file=''${out%%:*}
      line=$(cut -d: -f2 <<< "$out")
      ''${EDITOR:-nvim} "+$line" "$file"
    }

    # fnix -- search nixpkgs and print the attribute path. Uses the local
    # flake registry, so it works offline against your pinned nixpkgs.
    fnix() {
      nix search nixpkgs "''${1:-}" --json 2>/dev/null \
        | jq -r 'to_entries[] | "\(.key|sub("^legacyPackages\\.[^.]+\\.";""))\t\(.value.description)"' \
        | fzf --delimiter='\t' --with-nth=1,2 \
        | cut -f1
    }
  '';

  home.packages = [ pkgs.jq ];  # used by fnix above
}
