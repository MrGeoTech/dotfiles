{
  imports = [
    ./global-nixos.nix

    # Odyssey G9: HDR (Hyprland flips the monitor to HDR when gamescope asks),
    # VRR, and FSR whenever a game renders below native resolution.
    # DXVK_HDR=1 lets DirectX 9-11 games (DXVK) offer HDR; vkd3d-proton
    # (DX12) and native Vulkan games don't need it.
    (import ./common/optional/apps/steam-full.nix {
      monitor = "DP-1";
      gamescopeArgs = ["--hdr-enabled" "--adaptive-sync" "-F" "fsr"];
      env.DXVK_HDR = "1";
    })
  ];

  host = {
    monitors = [
      # Odyssey G9. 240Hz depends on the EDID override in
      # hosts/mrgeotech-pc/default.nix and the OSD Refresh Rate being 240Hz.
      # vrr = 2 limits VRR to fullscreen: this VA panel flickers with VRR on
      # the desktop, where the framerate is constantly bouncing around.
      {
        output = "DP-1";
        mode = "5120x1440@240";
        position = "1920x0";
        scale = 1;
        bitdepth = 10;
        vrr = 2;
      }
      {
        output = "HDMI-A-1";
        mode = "highres";
        position = "0x360";
        scale = 1;
      }
    ];

    # Desktop: no reason to blank and lock on a timer.
    idle = false;
  };
}
