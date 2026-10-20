# UPS (CyberPower 1500VA AVR over USB). NUT reads it and Telegraf picks
# its numbers up (series upsd_<field>); where they go is metrics.nix.
{...}: {
  power.ups = {
    enable = true;
    mode = "standalone";
    ups.cyberpower = {
      driver = "usbhid-ups";
      port = "auto";
      description = "CyberPower 1500VA AVR";
    };
    # Metrics only: no upsmon, so nothing shuts the machine down on low
    # battery. Add a power.ups.upsmon.monitor entry to get that.
    upsmon.enable = false;
  };

  services.telegraf.extraConfig.inputs.upsd = [
    {
      force_float = true;
      stringify_ids = true;
      # Status comes as tags too (status_OL, status_OB, ...), which would
      # start a new series every time the power flips. status_flags
      # already has the same bits.
      tagexclude = ["status_*"];
    }
  ];
  systemd.services.telegraf = {
    after = ["upsd.service"];
    wants = ["upsd.service"];
  };
}
