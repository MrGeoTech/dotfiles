# Bluetooth stack: bluez + PipeWire audio + bluetuith (TUI management).
#
# Replaces the `services.blueman.enable = true;` line in
# hosts/common/optional/default.nix -- delete it there, or this module's
# intent is defeated (blueman-applet + blueman-tray were ~64 MB resident).
#
# Import from hosts/common/optional/default.nix:
#   imports = [ ... ./bluetooth.nix ... ];
#
# Reference: https://wiki.nixos.org/wiki/Bluetooth
{
  config,
  lib,
  pkgs,
  ...
}: {
  ##########################################################################
  # Controller
  ##########################################################################
  hardware.bluetooth = {
    enable = true;

    # false = adapter stays off until something asks for it. Saves idle power
    # and sidesteps the combo wifi/bt card interference the wiki warns about.
    # Set true if you want headphones to reconnect without `bluetoothctl power on`.
    #
    # NOTE: this option is what writes Policy.AutoEnable into main.conf. Do NOT
    # also set `settings.Policy.AutoEnable` below -- you'll get a conflicting
    # definition error at eval time.
    powerOnBoot = true;

    settings = {
      General = {
        # Advertised name when discoverable. Uses the host name so the two
        # machines are distinguishable when pairing from a phone.
        Name = config.networking.hostName;

        # dual = BR/EDR (headsets, controllers) + LE (mice, trackers).
        ControllerMode = "dual";

        # Required for battery-level reporting over BAS/AVRCP. bluetuith reads
        # this, and it's what makes `upower -d` show your headphone charge.
        # Flagged experimental upstream; in practice this is what everyone runs.
        Experimental = true;
        KernelExperimental = true;

        # Keeps the controller in page-scan mode so already-paired devices
        # reconnect in ~1s instead of ~5s. Costs a small amount of idle power --
        # drop this line if you're chasing battery life over convenience.
        FastConnectable = true;

        # Re-pair silently instead of erroring when a device that uses the
        # "Just Works" (no PIN) association model rotates its keys. This is the
        # fix for headphones that pair once and then refuse to reconnect.
        JustWorksRepairing = "always";

        # Let a device expose several profiles at once, e.g. a headset that is
        # simultaneously an A2DP sink and an AVRCP remote.
        MultiProfile = "multiple";

        # Stop broadcasting after 30s of discoverability; stay pairable
        # indefinitely once you've explicitly entered pairing mode.
        DiscoverableTimeout = 30;
        PairableTimeout = 0;
      };

      Policy = {
        # Retry reconnects with backoff instead of giving up after one attempt.
        # Matters when a headset wanders out of range and comes back.
        ReconnectAttempts = 7;
        ReconnectIntervals = "1,2,4,8,16,32,64";
        AutoConnectTimeout = 60;
      };
    };
  };

  ##########################################################################
  # Audio -- PipeWire, not PulseAudio
  ##########################################################################
  # The wiki's audio sections are almost entirely PulseAudio-era and do not
  # apply here: `pulseaudioFull` for codecs, `pacmd set-card-profile`,
  # `module-switch-on-connect`, and `General.Enable = "Source,Sink,..."` (which
  # bluez5 rejects outright) are all obsolete. On PipeWire, codec support is
  # compiled in and the knobs live in wireplumber.
  services.pipewire.wireplumber.extraConfig."10-bluez" = {
    "monitor.bluez.properties" = {
      # SBC-XQ: higher-bitrate SBC. Audibly better than stock SBC and works on
      # essentially every device, unlike aptX/LDAC which need vendor support.
      "bluez5.enable-sbc-xq" = true;

      # mSBC: wideband speech for the headset profile. Turns calls from
      # 8 kHz telephone mush into something usable.
      "bluez5.enable-msbc" = true;

      # Route volume changes to the device's own hardware volume rather than
      # attenuating in software (preserves bit depth).
      "bluez5.enable-hw-volume" = true;

      # Prefer high-quality playback; only fall back to the low-quality
      # bidirectional headset profile when something actually opens the mic.
      "bluez5.roles" = [
        "a2dp_sink"
        "a2dp_source"
        "bap_sink"
        "bap_source"
        "hfp_hf"
        "hfp_ag"
        "hsp_hs"
        "hsp_ag"
      ];

      # Codec preference order. PipeWire negotiates the best mutually
      # supported one; listing them makes the intent explicit.
      "bluez5.codecs" = [ "ldac" "aptx_hd" "aptx" "aac" "sbc_xq" "sbc" ];
    };
  };

  ##########################################################################
  # Battery reporting
  ##########################################################################
  # Surfaces device charge to anything that speaks UPower -- waybar, bluetuith,
  # and `upower -d`. Pairs with General.Experimental above; without that, the
  # BatteryProvider1 interface never appears.
  services.upower.enable = true;

  ##########################################################################
  # File transfer (OBEX)
  ##########################################################################
  # Lets a phone push files to ~/Downloads. bluetuith acts as the pairing agent
  # and will prompt for confirmation on each transfer.
  #
  # Add `--auto-accept` to skip the prompt -- convenient, but it means any
  # connected device can write into your Downloads unattended. Left off here.
  #
  # Debug with: journalctl --user -f -u obex
  systemd.user.services.obex = {
    description = "Bluetooth OBEX object push (receives into ~/Downloads)";
    serviceConfig = {
      Type = "dbus";
      BusName = "org.bluez.obex";
      ExecStart = "${pkgs.bluez}/libexec/bluetooth/obexd --root=%h/Downloads";
    };
  };

  ##########################################################################
  # Tooling
  ##########################################################################
  environment.systemPackages = with pkgs; [
    bluetuith # TUI manager: pair, connect, trust, transfer files, PAN
    bluez # bluetoothctl, btmgmt, hcitool
    bluez-tools # bt-adapter, bt-device, bt-obex -- scriptable one-shots
  ];

  # Uncomment for Xbox controllers over Bluetooth (rumble + correct axis
  # mapping, which the in-kernel xpad driver doesn't do wirelessly).
  # Most relevant on the steam-machine host.
  hardware.xpadneo.enable = true;

  # If you removed services.blueman.enable from default.nix, this line is
  # unnecessary. Kept commented as a way to force it off during migration if
  # some other module pulls it back in.
  services.blueman.enable = lib.mkForce false;
}
