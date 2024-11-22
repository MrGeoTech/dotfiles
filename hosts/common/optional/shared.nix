{ pkgs, ... }: {
    systemd.timers = {
        "shared-fs" = {
            wantedBy = [ "timers.target" ];
            timerConfig = {
                OnBootSec = "15sec";
                OnUnitActiveSec = "2min";
                Unit = "shared-fs.service";
            };
        };
    };

    systemd.services = {
        "shared-fs" = {
            # TODO: Fix ssh port on server
            script = ''
                #rsync -auqpEXgtUz --port=2049 --delete --safe-links /home/mrgeotech/Desktop/ mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/Desktop/
                #rsync -auqpEXgtUz --port=2049 --delete --safe-links mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/Desktop/ /home/mrgeotech/Desktop/
                rsync -auqpEXgtUz -del --safe-links -e 'ssh -p 2049' /home/mrgeotech/Desktop/ mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/Desktop/
                rsync -auqpEXgtUz -del --safe-links -e 'ssh -p 2049' mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/Desktop/ /home/mrgeotech/Desktop/

                rsync -auqpEXgtUz -del --safe-links -e 'ssh -p 2049' /home/mrgeotech/Documents/ mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/Documents/
                rsync -auqpEXgtUz -del --safe-links -e 'ssh -p 2049' mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/Documents/ /home/mrgeotech/Documents/

                rsync -auqpEXgtUz -del --safe-links -e 'ssh -p 2049' /home/mrgeotech/Downloads/ mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/Downloads/
                rsync -auqpEXgtUz -del --safe-links -e 'ssh -p 2049' mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/Downloads/ /home/mrgeotech/Downloads/

                rsync -auqpEXgtUz -del --safe-links -e 'ssh -p 2049' /home/mrgeotech/Pictures/ mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/Pictures/
                rsync -auqpEXgtUz -del --safe-links -e 'ssh -p 2049' mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/Pictures/ /home/mrgeotech/Pictures/

                rsync -auqpEXgtUz -del --safe-links -e 'ssh -p 2049' /home/mrgeotech/Projects/ mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/Projects/
                rsync -auqpEXgtUz -del --safe-links -e 'ssh -p 2049' mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/Projects/ /home/mrgeotech/Projects/
                
                rsync -auqpEXgtUz -del --safe-links -e 'ssh -p 2049' /home/mrgeotech/School/ mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/School/
                rsync -auqpEXgtUz -del --safe-links -e 'ssh -p 2049' mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/School/ /home/mrgeotech/School/
                
                rsync -auqpEXgtUz -del --safe-links -e 'ssh -p 2049' /home/mrgeotech/Videos/ mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/Videos/
                rsync -auqpEXgtUz -del --safe-links -e 'ssh -p 2049' mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/Videos/ /home/mrgeotech/Videos/
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
                ExecStop = "rsync -auqpEXgtUz -del --safe-links -e 'ssh -p 2049' /home/mrgeotech/Desktop/ mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/ && rsync -auqpEXgtUz -del --safe-links -e 'ssh -p 2049' /home/mrgeotech/Documents/ mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/ && rsync -auqpEXgtUz -del --safe-links -e 'ssh -p 2049' /home/mrgeotech/Downloads/ mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/ && rsync -auqpEXgtUz -del --safe-links -e 'ssh -p 2049' /home/mrgeotech/Pictures/ mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/ && rsync -auqpEXgtUz -del --safe-links -e 'ssh -p 2049' /home/mrgeotech/Projects/ mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/ && rsync -auqpEXgtUz -del --safe-links -e 'ssh -p 2049' /home/mrgeotech/School/ mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/ && rsync -auqpEXgtUz -del --safe-links -e 'ssh -p 2049' /home/mrgeotech/Videos/ mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/";
            };
            path = with pkgs; [ rsync openssh ];
        };
    };
               }
