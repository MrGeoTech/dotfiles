# UPS (CyberPower 1500VA AVR over USB) metrics. NUT reads the UPS, Telegraf
# pushes its numbers to VictoriaMetrics the same way weaponized_autism's
# Telegraf does (Influx line protocol on /write, series named upsd_<field>),
# and `ups-dash` shows them in the terminal with grafterm.
#
# Login for VictoriaMetrics lives outside git, like the wireguard keys:
#   ~/.secrets/metrics.env   ->   METRICS_PASSWORD=<telemetry-password>
{
  # VictoriaMetrics on the weaponized_autism VM, reached over wg0.
  metricsUrl ? "http://10.0.1.50:8428",
  metricsUser ? "wa",
}: {pkgs, ...}: let
  envFile = "/home/mrgeotech/.secrets/metrics.env";

  # Same raw-values-only rule as the other services: percent and watts are
  # worked out here at query time, not stored.
  sel = ''ups_name="cyberpower"'';
  q = expr: {
    datasourceID = "vm";
    inherit expr;
  };
  stat = title: w: unit: expr: {
    inherit title;
    gridPos.w = w;
    singlestat = {
      inherit unit;
      decimals = 1;
      thresholds = [{color = "#89b4fa";}];
      query = q expr;
    };
  };
  graph = title: w: unit: queries: {
    inherit title;
    gridPos.w = w;
    graph = {
      visualization = {
        legend.rightSide = true;
        yAxis = {
          inherit unit;
          decimals = 0;
        };
      };
      inherit queries;
    };
  };
  watts = "upsd_load_percent{${sel}} * upsd_nominal_power{${sel}} / 100";

  dashboard = pkgs.writeText "ups-dashboard.json" (builtins.toJSON {
    version = "v1";
    # Without the login; ups-dash swaps in the real one (grafterm user
    # datasources only replace ids the dashboard already has).
    datasources.vm.prometheus.address = metricsUrl;
    dashboard.widgets = [
      {
        title = "Power";
        gridPos.w = 20;
        singlestat = {
          query = q ''floor(upsd_status_flags{${sel}} / 16) % 2'';
          valueText = ''{{ if (gt .value 0.5) }}ON BATTERY{{ else }}MAINS{{ end }}'';
          thresholds = [
            {color = "#a6e3a1";}
            {
              color = "#f38ba8";
              startValue = 0.5;
            }
          ];
        };
      }
      (stat "Load (W)" 20 "none" watts)
      (stat "Load" 20 "percent" "upsd_load_percent{${sel}}")
      (stat "Runtime left" 20 "seconds" "upsd_time_left_ns{${sel}} / 1e9")
      {
        title = "Battery";
        gridPos.w = 20;
        gauge = {
          query = q "upsd_battery_charge_percent{${sel}}";
          percentValue = true;
          min = 0;
          max = 100;
          thresholds = [
            {color = "#f38ba8";}
            {
              color = "#f9e2af";
              startValue = 30;
            }
            {
              color = "#a6e3a1";
              startValue = 70;
            }
          ];
        };
      }
      (graph "Load (W)" 100 "none" [
        ((q watts) // {legend = "watts";})
      ])
      (graph "Voltage" 50 "none" [
        ((q "upsd_input_voltage{${sel}}") // {legend = "input";})
        ((q "upsd_output_voltage{${sel}}") // {legend = "output";})
      ])
      (graph "Battery" 50 "none" [
        ((q "upsd_battery_charge_percent{${sel}}") // {legend = "charge %";})
        ((q "upsd_time_left_ns{${sel}} / 6e10") // {legend = "runtime min";})
      ])
    ];
  });

  # grafterm only speaks to the metrics server. The login goes in the
  # address (http://user:pass@host) inside a runtime-only datasources file,
  # never in the nix store.
  ups-dash = pkgs.writeShellScriptBin "ups-dash" ''
    set -eu
    . ${envFile}
    ds=$(mktemp "''${XDG_RUNTIME_DIR:-/tmp}/ups-dash.XXXXXX.json")
    trap 'rm -f "$ds"' EXIT
    chmod 600 "$ds"
    url=${metricsUrl}
    printf '{"version":"v1","datasources":{"vm":{"prometheus":{"address":"%s"}}}}' \
      "''${url%%://*}://${metricsUser}:$METRICS_PASSWORD@''${url#*://}" > "$ds"
    ${pkgs.grafterm}/bin/grafterm -c ${dashboard} -u "$ds" -d "''${1:-3h}" -r 10s
  '';
in {
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

  services.telegraf = {
    enable = true;
    environmentFiles = [envFile];
    extraConfig = {
      agent = {
        interval = "10s";
        flush_interval = "10s";
      };
      outputs.influxdb = [
        {
          urls = [metricsUrl];
          database = "telegraf";
          skip_database_creation = true;
          username = metricsUser;
          password = "$METRICS_PASSWORD";
        }
      ];
      inputs.upsd = [
        {
          force_float = true;
          stringify_ids = true;
          # Status comes as tags too (status_OL, status_OB, ...), which would
          # start a new series every time the power flips. status_flags
          # already has the same bits.
          tagexclude = ["status_*"];
        }
      ];
    };
  };
  systemd.services.telegraf = {
    after = ["upsd.service"];
    wants = ["upsd.service"];
  };

  environment.systemPackages = [ups-dash];
}
