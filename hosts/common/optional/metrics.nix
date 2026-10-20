# Machine metrics to VictoriaMetrics, the same way weaponized_autism's
# Telegraf does it (Influx line protocol on /write, series named
# <measurement>_<field>). Inputs come from other files (ups.nix).
# `ups-dash` shows the UPS ones in the terminal with grafterm.
#
# Login lives outside git, like the wireguard keys:
#   ~/.secrets/metrics.env   ->   METRICS_PASSWORD=<telemetry-password>
{
  url,
  user,
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
    datasources.vm.prometheus.address = url;
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
    url=${url}
    printf '{"version":"v1","datasources":{"vm":{"prometheus":{"address":"%s"}}}}' \
      "''${url%%://*}://${user}:$METRICS_PASSWORD@''${url#*://}" > "$ds"
    ${pkgs.grafterm}/bin/grafterm -c ${dashboard} -u "$ds" -d "''${1:-3h}" -r 10s
  '';
in {
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
          urls = [url];
          database = "telegraf";
          skip_database_creation = true;
          username = user;
          password = "$METRICS_PASSWORD";
        }
      ];
    };
  };

  environment.systemPackages = [ups-dash];
}
