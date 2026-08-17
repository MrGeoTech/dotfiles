# https://github.com/nix-community/nh
#
# Goes in hosts/common/core/ (system level, not home-manager).
#
# Replaces `nixos-rebuild switch --flake .#host` with `nh os switch`, and adds
# the thing nixos-rebuild never had: a readable diff of what actually changed
# between generations, rendered before it asks to proceed. Also folds
# `nix-collect-garbage` into a scheduled unit with sane retention.
{ config, ... }: {
  programs.nh = {
    enable = true;

    # Point at your flake so `nh os switch` works from any directory.
    # Adjust if your checkout lives elsewhere.
    flake = "/home/mrgeotech/nixos-config";

    clean = {
      enable = true;
      dates = "weekly";
      # Keep a fortnight of history and never drop below 5 generations, so a
      # bad rebuild is always one `nh os rollback` away.
      extraArgs = "--keep-since 14d --keep 5";
    };
  };

  # nh reads these for the diff view; without them it falls back to plain text.
  environment.sessionVariables = {
    NH_NO_CHECKS = "0";
  };
}
