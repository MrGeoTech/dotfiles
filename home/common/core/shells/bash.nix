{
  programs.bash = {
    enable = true;
    enableCompletion = true;

    initExtra = ''
      # Auto-search nixpkgs for an unknown command and, after an explicit
      # confirmation (comma reads COMMA_ASK_TO_CONFIRM, set in
      # ../default.nix), run it sandboxed via `nix shell` instead of
      # installing anything. The missing command is only ever forwarded
      # through argv to `comma`, never interpolated into a string, and
      # this is skipped entirely outside a real terminal so non-interactive
      # scripts still fail normally instead of hanging on a prompt.
      command_not_found_handle() {
        if [ -n "''${1:-}" ] && [ -t 0 ] && command -v comma >/dev/null 2>&1; then
          comma "$@"
          return $?
        fi
        echo "''${1:-command}: command not found" >&2
        return 127
      }
    '';
  };
}
