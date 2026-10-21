# Terminal dashboards (grafterm) over the metrics each machine keeps itself
# (metrics.nix). Only talks to the servers listed here.
#
#   dash              list dashboards
#   dash <name> [3h]  open one, showing the last 3h (default)
#
# servers: VictoriaMetrics (or any Prometheus API) to read from. `name` is
# what a dashboard query uses as its datasourceID.
#   { name = "wa"; ip = "10.0.1.50"; port = 8428; user = "wa";
#     password = "wa-metrics-password"; }
# port defaults to 8428; user and password only if it wants a login.
# password is a key in secrets/metrics.yaml (sops), set it with
#   sops set hosts/common/optional/secrets/metrics.yaml '["<key>"]' '"<pw>"'
# sops-nix decrypts it to /run/secrets (ram only, readable by mrgeotech);
# `dash` reads it from there, it never reaches the nix store.
#
# dashboards: { name; config; } where config is a grafterm dashboard
# (github.com/slok/grafterm/blob/master/docs/cfg.md) minus `datasources`,
# which is filled in from servers.
{
  servers,
  dashboards,
}: {
  config,
  pkgs,
  lib,
  ...
}: let
  address = s: "http://${s.ip}:${toString (s.port or 8428)}";

  # Every dashboard knows every server, without the login. grafterm only
  # lets the runtime file (below) swap in ids the dashboard already has.
  datasources = lib.listToAttrs (map (s: lib.nameValuePair s.name {prometheus.address = address s;}) servers);

  dir = pkgs.linkFarm "dash-dashboards" (map (d: {
      name = "${d.name}.json";
      path = pkgs.writeText "dash-${d.name}.json" (builtins.toJSON ({version = "v1";} // d.config // {inherit datasources;}));
    })
    dashboards);

  # Servers with a login get it put in their address (http://user:pass@host)
  # in a user datasources file that only exists while dash runs.
  authed = lib.filter (s: s ? password) servers;
  authEntry = s: ''
    printf '%s"${s.name}":{"prometheus":{"address":"http://${s.user}:%s@${s.ip}:${toString (s.port or 8428)}"}}' "$sep" "$(tr -d '\n' < ${config.sops.secrets.${s.password}.path})"
    sep=,
  '';

  dash = pkgs.writeShellScriptBin "dash" ''
    set -eu
    f=${dir}/''${1:-}.json
    if [ -z "''${1:-}" ] || [ ! -e "$f" ]; then
      [ -n "''${1:-}" ] && echo "no dashboard: $1" >&2
      echo "dashboards:" >&2
      for d in ${dir}/*.json; do d=''${d##*/}; echo "  ''${d%.json}" >&2; done
      exit 1
    fi
    ${lib.optionalString (authed != []) ''
      datasources() {
        sep=
        printf '{"version":"v1","datasources":{'
        ${lib.concatMapStrings authEntry authed}
        printf '}}'
      }
    ''}
    # <(datasources) is a pipe, so the password is never copied to a file. It has
    # to stay on this line: bash closes it once the line that made it ends.
    ${pkgs.grafterm}/bin/grafterm -c "$f" -d "''${2:-3h}" -r 10s \
      ${lib.optionalString (authed != []) "-u <(datasources)"}
  '';
in {
  sops.secrets = lib.listToAttrs (map (s:
    lib.nameValuePair s.password {
      sopsFile = ./secrets/metrics.yaml;
      owner = "mrgeotech";
      mode = "0400";
    })
  authed);

  environment.systemPackages = [dash];
}
