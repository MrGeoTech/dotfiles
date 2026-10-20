# Remote-use mode: `headless on` blanks the screens and drops the CPU and
# GPU to their lowest-power settings; `headless off` puts them back. The
# machine stays awake, so ssh/wireguard (and the windows VM) keep working.
{pkgs, ...}: let
  hyprctl = "${pkgs.hyprland}/bin/hyprctl";
  # hyprctl needs the session's runtime dir to find the Hyprland socket.
  dpms = state: ''
    ${pkgs.util-linux}/bin/runuser -u mrgeotech -- \
      env XDG_RUNTIME_DIR=/run/user/1000 ${hyprctl} -i 0 dispatch dpms ${state} || true
  '';
  setAll = glob: value: ''
    for f in ${glob}; do echo ${value} > "$f" || true; done
  '';
in {
  systemd.services.headless = {
    description = "Low-power remote-use mode";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${dpms "off"}
      ${setAll "/sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference" "power"}
      ${setAll "/sys/class/drm/card*/device/power_dpm_force_performance_level" "low"}
    '';
    # Same values the boot config sets (see default.nix tmpfiles rule).
    preStop = ''
      ${setAll "/sys/class/drm/card*/device/power_dpm_force_performance_level" "auto"}
      ${setAll "/sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference" "balance_performance"}
      ${dpms "on"}
    '';
  };

  environment.systemPackages = [
    (pkgs.writeShellScriptBin "headless" ''
      case "$1" in
        on) exec sudo systemctl start headless ;;
        off) exec sudo systemctl stop headless ;;
        *) systemctl is-active headless; echo "usage: headless on|off" >&2; exit 1 ;;
      esac
    '')
  ];
}
