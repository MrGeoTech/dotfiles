{ config, ... }:
{
  services.hypridle = {
    enable = config.host.idle;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch 'hl.dsp.dpms(\"on\")'";
      };
      listener = [
        {
          timeout = 1800;
          on-timeout = "hyprctl dispatch 'hl.dsp.dpms(\"off\")'";
          on-resume = "hyprctl dispatch 'hl.dsp.dpms(\"on\")'";
        }
        {
          timeout = 3600;
          on-timeout = "loginctl lock-session";
        }
      ];
    };
  };
}
