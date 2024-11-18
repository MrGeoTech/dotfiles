{ pkgs, ... }: {
  systemd.timers = {
    "shared-fs-pull" = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "15sec";
        OnUnitActiveSec = "2min";
        Unit = "shared-fs-pull.service";
      };
    };
    "shared-fs-push" = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "2min";
        OnUnitActiveSec = "2min";
        Unit = "shared-fs-push.service";
      };
    };
  };

  systemd.services = {
    "shared-fs-push" = {
      script = ''
	rsync -auqpEXgtUz -del --safe-links -e 'ssh -p 2049' /shared mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "mrgeotech";
      };
      path = with pkgs; [ rsync openssh ];
    };
    "shared-fs-pull" = {
      script = ''
	rsync -auqpEXgtUz -del --safe-links -e 'ssh -p 2049' mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/ /shared
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "mrgeotech";
      };
      path = with pkgs; [ rsync openssh ];
    };
  };
}
