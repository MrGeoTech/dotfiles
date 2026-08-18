# https://github.com/catppuccin/nix
#
# The module is imported (see flake.nix) but unused for now -- every app's
# Catppuccin theme in this repo is still hand-configured (nvim, fzf, delta,
# ghostty, ...) rather than through the module's per-program
# `catppuccin.<port>.enable` toggles. Pin `autoEnable` to match `enable` so a
# future version of the module, where `autoEnable` controls per-port
# enrollment and `enable` becomes a pure kill-switch, doesn't change that.
{
  catppuccin = {
    enable = true;
    autoEnable = true;
  };
}
