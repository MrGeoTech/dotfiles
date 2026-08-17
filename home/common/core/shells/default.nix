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
    # lg
    lg = "lazygit";
    # network
    myip = "curl http://ipecho.net/plain; echo";
    # df
    df = "df -ahiT --total";
    # ps
    ps = "ps auxf";
    psgrep = "ps aux | grep -v grep | grep -i -e VSZ -e";
    # nix operations 
    update = "( cd /etc/nixos/ && nh os switch )";
    update-versions = "( cd /etc/nixos/ && nix flake update )";
    clean-system = "sudo nix-collect-garbage --delete-older-than 2d --cores 16 && nix-collect-garbage --delete-older-than 2d --cores 16";
  };
  home.sessionPath = [
    "$HOME/.local/bin"
    "/var/lib/flatpak/exports/bin"
  ];
  home.sessionVariables = {
    EDITOR = "nvim";
    TERM = "xterm-256color";
    USE_EDITOR = "$EDITOR";
    BROWSER = "vivaldi";
  };
}
