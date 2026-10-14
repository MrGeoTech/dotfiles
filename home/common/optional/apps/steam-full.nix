# `steam-full`: Steam running inside gamescope with this machine's tuning,
# so every game gets it without per-game launch options. Plain `steam` is
# left alone as the fallback for games that misbehave in gamescope.
#
# Import with arguments from home/<hostname>.nix, like
# hosts/common/optional/wireguard.nix:
#   (import ./common/optional/apps/steam-full.nix { gamescopeArgs = [ ... ]; })
{
  # Extra gamescope flags for this machine: HDR, VRR, upscaling, overlay, ...
  gamescopeArgs ? [],
  # Environment for Steam and every game it launches.
  env ? {},
  # Hyprland output to open on and size gamescope to. null means whichever
  # monitor has focus at launch.
  monitor ? null,
}: {
  config,
  lib,
  pkgs,
  ...
}: let
  nestedArgs = [
    "-f" # some games crash in a windowed gamescope (ArchWiki)
    "--mangoapp" # performance overlay; configured by programs.mangohud.settings
  ];

  # -gamepadui is Big Picture, the UI gamescope's Steam integration (-e) is
  # built around. -steamos3 turns on the SteamOS power menu, whose "Switch to
  # Desktop" is the only way out of Big Picture under gamescope. Same flags
  # as ChimeraOS's gamescope-session-steam, minus the Steam Deck spoofing.
  steamArgs = ["-gamepadui" "-steamos3" "-pipewire-dmabuf"];

  # The SteamOS commands Steam calls under -steamos3. Stand-ins modelled on
  # ChimeraOS's: "Switch to Desktop" just quits Steam (ending gamescope),
  # and there are no OS updates or branches to offer.
  steamosStubs = pkgs.symlinkJoin {
    name = "steamos-stubs";
    paths = [
      (pkgs.writeShellScriptBin "steamos-session-select" "exec steam -shutdown")
      (pkgs.writeShellScriptBin "steamos-select-branch" "exit 0")
      (pkgs.writeShellScriptBin "steamos-update" ''
        # --supports-duplicate-detection is a capability probe; anything else
        # is a check or an update, and 7 tells Steam there is nothing to do.
        [ "''${1-}" = --supports-duplicate-detection ] && exit 0
        exit 7
      '')
    ];
  };

  # gamescope starts mangoapp with its own environment, which still has
  # Hyprland's WAYLAND_DISPLAY. GLFW then picks Wayland, but mangoapp only
  # works on gamescope's X server, so it crashes ("X11: Platform not
  # initialized") and no overlay ever shows. gamescope finds mangoapp on
  # PATH, so shadow it with one that drops the variable.
  mangoapp = pkgs.writeShellScriptBin "mangoapp" ''
    unset WAYLAND_DISPLAY
    exec ${pkgs.mangohud}/bin/mangoapp "$@"
  '';

  envArgs = lib.mapAttrsToList (k: v: "${k}=${v}") env;

  steam-full = pkgs.writeShellApplication {
    name = "steam-full";
    runtimeInputs = [pkgs.jq pkgs.procps mangoapp];
    text = ''
      # Steam is single-instance: a second launch hands off to the running
      # client and exits, which would take gamescope down with it.
      if pgrep -x steam >/dev/null; then
        steam -shutdown
        for _ in $(seq 30); do
          pgrep -x steam >/dev/null || break
          sleep 1
        done
      fi

      # gamescope defaults to 1280x720, so match the monitor's mode.
      size=()
      if mode=$(hyprctl -j monitors 2>/dev/null | jq -er --arg m ${lib.escapeShellArg (toString monitor)} '
        .[] | select(if $m == "" then .focused else .name == $m end)
            | "\(.width) \(.height) \(.refreshRate | round)"'); then
        read -r w h r <<<"$mode"
        size=(-W "$w" -H "$h" -r "$r")
      fi

      # Under -steamos3, Restart and Shut Down in Steam's power menu just
      # drop these files and quit, leaving the actual reboot to the session.
      runtime=''${XDG_RUNTIME_DIR:-/tmp}
      export STEAMOS_STEAM_REBOOT_SENTINEL=$runtime/steam-full-reboot
      export STEAMOS_STEAM_SHUTDOWN_SENTINEL=$runtime/steam-full-shutdown
      rm -f "$STEAMOS_STEAM_REBOOT_SENTINEL" "$STEAMOS_STEAM_SHUTDOWN_SENTINEL"

      # Under -steamos3, Steam also manages the default audio device, which
      # fights WirePlumber and can knock Bluetooth headphones off.
      export STEAM_DISABLE_AUDIO_DEVICE_SWITCHING=1

      # Steam's sandbox keeps the outer PATH, so the stubs are visible inside.
      gamescope -e ${lib.escapeShellArgs (nestedArgs ++ gamescopeArgs)} "''${size[@]}" \
        -- env PATH="${steamosStubs}/bin:$PATH" ${lib.escapeShellArgs envArgs} \
        steam ${lib.escapeShellArgs steamArgs} || true

      if [ -e "$STEAMOS_STEAM_REBOOT_SENTINEL" ]; then
        rm -f "$STEAMOS_STEAM_REBOOT_SENTINEL"
        systemctl reboot
      elif [ -e "$STEAMOS_STEAM_SHUTDOWN_SENTINEL" ]; then
        rm -f "$STEAMOS_STEAM_SHUTDOWN_SENTINEL"
        systemctl poweroff
      fi
    '';
  };
in {
  home.packages = [steam-full];

  xdg.desktopEntries.steam-full = {
    name = "Steam (gamescope)";
    comment = "Steam Big Picture inside gamescope, tuned for this machine";
    exec = "steam-full";
    icon = "steam";
    categories = ["Game"];
  };

  wayland.windowManager.hyprland.extraLuaFiles."25-steam-full" =
    lib.mkIf config.wayland.windowManager.hyprland.enable {
      autoLoad = true;
      content = ''
        -- GENERATED BY NIX (apps/steam-full.nix). Do not edit by hand.
        hl.window_rule({
          name = "steam-full",
          match = { class = "^gamescope$" },
          ${lib.optionalString (monitor != null) ''monitor = "${monitor}",''}
          fullscreen = true,
          idle_inhibit = "fullscreen",
        })
      '';
    };
}
