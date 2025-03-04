{ hostname, pkgs, ... }: {
  imports = [
    ./bash.nix
    ./zsh.nix
  ];
  home.shellAliases = {
    # rm alias
    rm = "rm -i";
    # clear
    clear = "clear -x";
    cls = "clear";
    # vim alias
    v = "nvim";
    vi = "nvim";
    vim = "nvim";
    # ll
    ll = "ls -al";
    # lg
    lg = "lazygit";
    # grep
    grep = "grep --color=auto";
    # network
    myip = "curl http://ipecho.net/plain; echo";
    # df
    df = "df -ahiT --total";
    # memory
    free = "free -mt";
    # ps
    ps = "ps auxf";
    psgrep = "ps aux | grep -v grep | grep -i -e VSZ -e";
    # update
    update = "( cd /etc/nixos/ && sudo nixos-rebuild switch --flake \".#$(hostname)\" )";
    update-versions = "( cd /etc/nixos/ && nix flake update )";
  };
  home.sessionPath = [
    "$HOME/.local/bin"
    "/var/lib/flatpak/exports/bin"
  ];
  home.sessionVariables = {
    EDITOR = "nvim";
    TERM = "xterm-256color";
    USE_EDITOR = "$EDITOR";
    VISUAL = "$EDITOR";
    BROWSER = "vivaldi";
  };
}
