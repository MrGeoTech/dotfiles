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
    # TODO: Fix ssh port on server
      script = ''
	      rsync -auqpEXgtUz -del --safe-links -e 'ssh -p 2049' /home/mrgeotech/Desktop mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/
	      rsync -auqpEXgtUz -del --safe-links -e 'ssh -p 2049' /home/mrgeotech/Documents mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/
	      rsync -auqpEXgtUz -del --safe-links -e 'ssh -p 2049' /home/mrgeotech/Downloads mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/
	      rsync -auqpEXgtUz -del --safe-links -e 'ssh -p 2049' /home/mrgeotech/Pictures mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/
	      rsync -auqpEXgtUz -del --safe-links -e 'ssh -p 2049' /home/mrgeotech/Projects mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/
	      rsync -auqpEXgtUz -del --safe-links -e 'ssh -p 2049' /home/mrgeotech/School mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/
	      rsync -auqpEXgtUz -del --safe-links -e 'ssh -p 2049' /home/mrgeotech/Videos mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "mrgeotech";
      };
      path = with pkgs; [ rsync openssh ];
    };
    "shared-fs-push-shutdown" = {
      serviceConfig = {
        Type = "oneshot";
        User = "mrgeotech";
        RemainAfterExit = true;
        # I hate this
        ExecStop = "rsync -auqpEXgtUz -del --safe-links -e 'ssh -p 2049' /home/mrgeotech/Desktop mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/ && rsync -auqpEXgtUz -del --safe-links -e 'ssh -p 2049' /home/mrgeotech/Documents mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/ && rsync -auqpEXgtUz -del --safe-links -e 'ssh -p 2049' /home/mrgeotech/Downloads mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/ && rsync -auqpEXgtUz -del --safe-links -e 'ssh -p 2049' /home/mrgeotech/Pictures mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/ && rsync -auqpEXgtUz -del --safe-links -e 'ssh -p 2049' /home/mrgeotech/Projects mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/ && rsync -auqpEXgtUz -del --safe-links -e 'ssh -p 2049' /home/mrgeotech/School mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/ && rsync -auqpEXgtUz -del --safe-links -e 'ssh -p 2049' /home/mrgeotech/Videos mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/";
      };
      path = with pkgs; [ rsync openssh ];
    };
    "shared-fs-pull" = {
      script = ''
	      rsync -auqpEXgtUz -del --safe-links -e 'ssh -p 2049' mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/Desktop /home/mrgeotech/
	      rsync -auqpEXgtUz -del --safe-links -e 'ssh -p 2049' mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/Documents /home/mrgeotech/
	      rsync -auqpEXgtUz -del --safe-links -e 'ssh -p 2049' mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/Downloads /home/mrgeotech/
	      rsync -auqpEXgtUz -del --safe-links -e 'ssh -p 2049' mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/Pictures /home/mrgeotech/
	      rsync -auqpEXgtUz -del --safe-links -e 'ssh -p 2049' mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/Projects /home/mrgeotech/
	      rsync -auqpEXgtUz -del --safe-links -e 'ssh -p 2049' mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/School /home/mrgeotech/
	      rsync -auqpEXgtUz -del --safe-links -e 'ssh -p 2049' mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/Videos /home/mrgeotech/
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "mrgeotech";
      };
      path = with pkgs; [ rsync openssh ];
    };
  };
}
