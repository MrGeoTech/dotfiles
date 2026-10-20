# Terminal dashboards (grafterm) over the metrics each machine keeps
# itself (metrics.nix). Only talks to those VictoriaMetrics servers.
{
  # VictoriaMetrics of the machine with the UPS.
  pc,
}: {pkgs, ...}: let
  # Same raw-values-only rule as the other services: percent and watts are
  # worked out here at query time, not stored.
  sel = ''ups_name="cyberpower"'';
  q = expr: {
    datasourceID = "pc";
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
    datasources.pc.prometheus.address = pc;
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

  ups-dash = pkgs.writeShellScriptBin "ups-dash" ''
    exec ${pkgs.grafterm}/bin/grafterm -c ${dashboard} -d "''${1:-3h}" -r 10s
  '';
in {
  environment.systemPackages = [ups-dash];
}
