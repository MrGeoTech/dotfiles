{
  pkgs,
  config,
  outputs,
  ...
}: {
  imports = [
    ./common/core
    ./common/optional/apps/gaming.nix
    ./common/optional/apps/gpg.nix
    ./common/optional/desktops/gtk.nix
    ./common/optional/desktops/qt5.nix
    ./common/optional/desktops/xdg.nix
  ];

  home = {
    username = "mrgeotech";
    homeDirectory = "/home/${config.home.username}";
    stateVersion = "24.11";
 
    sessionVariables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\\\${HOME}/.steam/root/compatibilitytools.d";
    };
    file."gamescope.sh" = {
      text = ''
        #!/usr/bin/env bash
        set -xeuo pipefail

        gamescopeArgs=(
          --adaptive-sync  # VRR support
          --hdr-enabled
          --mangoapp       # performance overlay
          --rt             # realtime scheduling
          --steam
          --force-grab-cursor
          -w 3840
          -h 2160
          -r 60
          --integer-scale
        )

        steamArgs=(
          -pipewire-dmabuf
          -tenfoot          # Big Picture mode
        )

        mangoConfig=(
          cpu_temp
          gpu_temp
          ram
          vram
        )

        mangoVars=(
          MANGOHUD=1
          MANGOHUD_CONFIG="$(IFS=,; echo "''${mangoConfig[*]}")"
        )

        export "''${mangoVars[@]}"
        exec gamescope "''${gamescopeArgs[@]}" -- steam "''${steamArgs[@]}"
      '';
      executable = true; # make it chmod +x
    };
  };
}
