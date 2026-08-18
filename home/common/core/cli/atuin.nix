# https://github.com/atuinsh/atuin
#
# Replaces zsh's history file with a SQLite database: fuzzy search, per-directory
# filtering, exit codes, duration, and the host a command ran on. Local-only by
# default -- nothing leaves the machine unless you run `atuin register`, which
# would let mrgeotech-pc and mrgeotech-zenbook share one history (end-to-end
# encrypted, self-hostable).
{
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;

    # Leave the up-arrow alone. Up should walk *this session's* history the way
    # it always has; Ctrl-R is where the fuzzy search lives. Rebinding both is
    # how atuin ends up feeling intrusive.
    flags = [ "--disable-up-arrow" ];

    settings = {
      # Vim keys in the search UI: opens in insert, Esc drops to normal, then
      # j/k/gg/G work. Matches how you move everywhere else.
      keymap_mode = "vim-insert";

      style = "compact";
      inline_height = 20;
      show_preview = true;
      show_help = false;

      search_mode = "fuzzy";
      # Start scoped to the current directory -- in a project you almost always
      # want that one build command, not every command you've ever run.
      # Ctrl-R again cycles: directory -> session -> host -> global.
      filter_mode = "directory";
      filter_mode_shell_up_key_binding = "session";

      # Treat each git repo as a workspace, so directory filtering follows the
      # project rather than the exact subdirectory you happen to be in.
      workspaces = true;

      # Enter runs the command, Tab puts it on the line to edit first.
      # Safer default than enter_accept = true when a destructive command
      # is one keystroke from executing.
      enter_accept = false;

      # Don't record these.
      history_filter = [
        "^ "            # leading space = private, same convention as HISTCONTROL
        "^sudo -S"      # piping a password in
        "^pass "
        "^sops "
      ];

      dialect = "us";
      update_check = false;  # Nix handles updates
    };
  };
}
