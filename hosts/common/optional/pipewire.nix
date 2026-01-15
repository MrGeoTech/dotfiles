{pkgs, ... }:
{
  # rtkit is optional but recommended
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  environment.systemPackages = with pkgs; [
    xfce4-pulseaudio-plugin
    pavucontrol
  ];

  # Configure media keys
  services.actkbd = {
    enable = true;
    bindings = [
      { keys = [ 122 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/amixer -q sset Master 5%-"; }
      { keys = [ 123 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/amixer -q sset Master 5%+"; }
      { keys = [ 121 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/amixer -q sset Master toggle"; }
    ];
  };
}
