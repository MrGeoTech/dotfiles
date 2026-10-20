# Metrics stay on the machine that makes them: Telegraf writes into a
# VictoriaMetrics running right here, same shape weaponized_autism uses
# (Influx line protocol on /write, series named <measurement>_<field>).
# Inputs come from other files (ups.nix). Dashboards (dashboards.nix) read
# it over wg0; the port is only open there (wg0 is trusted, see
# wireguard.nix), nothing is pushed anywhere.
{...}: {
  services.victoriametrics = {
    enable = true;
    listenAddress = ":8428";
    retentionPeriod = "100y";
  };

  services.telegraf = {
    enable = true;
    extraConfig = {
      agent = {
        interval = "10s";
        flush_interval = "10s";
      };
      outputs.influxdb = [
        {
          urls = ["http://127.0.0.1:8428"];
          database = "telegraf";
          skip_database_creation = true;
        }
      ];
    };
  };
  systemd.services.telegraf = {
    after = ["victoriametrics.service"];
    wants = ["victoriametrics.service"];
  };
}
