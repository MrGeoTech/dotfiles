{
  imports = [
    ./global-nixos.nix

    # Meteor Lake iGPU: the useful knob here is FSR, so dropping a game's
    # resolution upscales cleanly instead of going blurry. No HDR or VRR:
    # nothing has confirmed the panel supports either.
    (import ./common/optional/apps/steam-full.nix {
      gamescopeArgs = ["-F" "fsr"];
    })

    # Hold SUPER + V to dictate. CPU only: base.en keeps it snappy.
    (import ./common/optional/apps/voice-type.nix {})
  ];

  host = {
    fontSize = 18;
    mouseSensitivity = 0.5;
    touchpadGestures = true;
  };
}
