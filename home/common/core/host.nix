# Per-machine knobs. Common modules read these instead of checking the
# hostname; each machine sets the ones it needs in home/<hostname>.nix.
{lib, ...}: let
  inherit (lib) mkOption types;
in {
  options.host = {
    monitors = mkOption {
      type = types.listOf (types.attrsOf (types.oneOf [types.str types.int types.float types.bool]));
      default = [
        {
          output = "";
          mode = "highres";
          position = "auto";
          scale = 1;
        }
      ];
      description = ''
        Hyprland monitor rules, one hl.monitor() call each. Every attribute
        becomes a field of the Lua table (see HL.MonitorSpec), so anything
        Hyprland accepts -- bitdepth, vrr, cm, ... -- can go here.
      '';
    };

    fontSize = mkOption {
      type = types.int;
      default = 12;
      description = "Base UI size: terminal font, waybar icons and Hyprland groupbar text.";
    };

    mouseSensitivity = mkOption {
      type = types.number;
      default = 1;
      description = "Hyprland input.sensitivity.";
    };

    touchpadGestures = mkOption {
      type = types.bool;
      default = false;
      description = "Three-finger horizontal swipe between workspaces.";
    };

    idle = mkOption {
      type = types.bool;
      default = true;
      description = "Turn the screens off and lock after inactivity (hypridle).";
    };
  };
}
