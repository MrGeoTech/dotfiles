{ pkgs, ... }: {
    # By making the actions commands, I can execute them whenever.
    environment.systemPackages = [
        # TODO: Fix ssh port on server
        (writeShellScriptBin "push-fs" ''
            #!/bin/bash
            rsync -ruqpEXgtUz --delete --safe-links -e "ssh -p 2049" /home/mrgeotech/Desktop/ mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/Desktop/
            rsync -ruqpEXgtUz --delete --safe-links -e "ssh -p 2049" /home/mrgeotech/Documents/ mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/Documents/
            rsync -ruqpEXgtUz --delete --safe-links -e "ssh -p 2049" /home/mrgeotech/Downloads/ mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/Downloads/
            rsync -ruqpEXgtUz --delete --safe-links -e "ssh -p 2049" /home/mrgeotech/Pictures/ mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/Pictures/
            rsync -ruqpEXgtUz --delete --safe-links -e "ssh -p 2049" /home/mrgeotech/Projects/ mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/Projects/
            rsync -ruqpEXgtUz --delete --safe-links -e "ssh -p 2049" /home/mrgeotech/School/ mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/School/
            rsync -ruqpEXgtUz --delete --safe-links -e "ssh -p 2049" /home/mrgeotech/Videos/ mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/Videos/
        '')
        (writeShellScriptBin "pull-fs" ''
            #!/bin/bash
            rsync -ruqpEXgtUz --delete --safe-links -e "ssh -p 2049" mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/Desktop/ /home/mrgeotech/Desktop/
            rsync -ruqpEXgtUz --delete --safe-links -e "ssh -p 2049" mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/Documents/ /home/mrgeotech/Documents/
            rsync -ruqpEXgtUz --delete --safe-links -e "ssh -p 2049" mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/Downloads/ /home/mrgeotech/Downloads/
            rsync -ruqpEXgtUz --delete --safe-links -e "ssh -p 2049" mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/Pictures/ /home/mrgeotech/Pictures/
            rsync -ruqpEXgtUz --delete --safe-links -e "ssh -p 2049" mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/Projects/ /home/mrgeotech/Projects/
            rsync -ruqpEXgtUz --delete --safe-links -e "ssh -p 2049" mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/School/ /home/mrgeotech/School/
            rsync -ruqpEXgtUz --delete --safe-links -e "ssh -p 2049" mrgeotech@mrgeotech.net:/mnt/Encypted/Shared/Videos/ /home/mrgeotech/Videos/
        '')
    ];

    systemd.timers."shared-fs-pull" = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
            OnBootSec = "15sec";
            OnUnitActiveSec = "2min";
            Unit = "shared-fs-pull.service";
        };
    };

    systemd.services = {
        "shared-fs" = {
            description = "Pulls on start and pushes on stop";
            wantedBy = [ "multi-user.target" ];
            serviceConfig = {
                User = "mrgeotech";
                ExecStart = "pull-fs";
                ExecStop = "push-fs";
            };
            path = with pkgs; [ rsync openssh ];
        };
        # Periodic pulling
        "shared-fs-pull" = {
            script = "pull-fs";
            wantedBy = [ "multi-user.target" ];
            serviceConfig = {
                Type = "oneshot";
                User = "mrgeotech";
            };
            path = with pkgs; [ rsync openssh ];
        };
    };
}
