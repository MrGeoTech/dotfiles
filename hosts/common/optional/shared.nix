{ pkgs, ... }: 
let
    # TODO: Fix ssh port on server
    push-fs = pkgs.writeShellScriptBin "push-fs" ''
        #!/bin/bash
        rsync -ruqpEXgtUz --delete --safe-links -e "ssh -p 14127" /home/mrgeotech/Desktop/ mrgeotech@10.0.1.1:/mnt/Encypted/Shared/Desktop/
        rsync -ruqpEXgtUz --delete --safe-links -e "ssh -p 14127" /home/mrgeotech/Documents/ mrgeotech@10.0.1.1:/mnt/Encypted/Shared/Documents/
        rsync -ruqpEXgtUz --delete --safe-links -e "ssh -p 14127" /home/mrgeotech/Downloads/ mrgeotech@10.0.1.1:/mnt/Encypted/Shared/Downloads/
        rsync -ruqpEXgtUz --delete --safe-links -e "ssh -p 14127" /home/mrgeotech/Pictures/ mrgeotech@10.0.1.1:/mnt/Encypted/Shared/Pictures/
        rsync -ruqpEXgtUz --delete --safe-links -e "ssh -p 14127" /home/mrgeotech/Projects/ mrgeotech@10.0.1.1:/mnt/Encypted/Shared/Projects/
        rsync -ruqpEXgtUz --delete --safe-links -e "ssh -p 14127" /home/mrgeotech/School/ mrgeotech@10.0.1.1:/mnt/Encypted/Shared/School/
        rsync -ruqpEXgtUz --delete --safe-links -e "ssh -p 14127" /home/mrgeotech/Videos/ mrgeotech@10.0.1.1:/mnt/Encypted/Shared/Videos/
    '';
#    push-fs-exec = "${push-fs}/bin/push-fs";
    
    pull-fs = pkgs.writeShellScriptBin "pull-fs" ''
        #!/bin/bash
        rsync -ruqpEXgtUz --delete --safe-links -e "ssh -p 14127" mrgeotech@10.0.1.1:/mnt/Encypted/Shared/Desktop/ /home/mrgeotech/Desktop/
        rsync -ruqpEXgtUz --delete --safe-links -e "ssh -p 14127" mrgeotech@10.0.1.1:/mnt/Encypted/Shared/Documents/ /home/mrgeotech/Documents/
        rsync -ruqpEXgtUz --delete --safe-links -e "ssh -p 14127" mrgeotech@10.0.1.1:/mnt/Encypted/Shared/Downloads/ /home/mrgeotech/Downloads/
        rsync -ruqpEXgtUz --delete --safe-links -e "ssh -p 14127" mrgeotech@10.0.1.1:/mnt/Encypted/Shared/Pictures/ /home/mrgeotech/Pictures/
        rsync -ruqpEXgtUz --delete --safe-links -e "ssh -p 14127" mrgeotech@10.0.1.1:/mnt/Encypted/Shared/Projects/ /home/mrgeotech/Projects/
        rsync -ruqpEXgtUz --delete --safe-links -e "ssh -p 14127" mrgeotech@10.0.1.1:/mnt/Encypted/Shared/School/ /home/mrgeotech/School/
        rsync -ruqpEXgtUz --delete --safe-links -e "ssh -p 14127" mrgeotech@10.0.1.1:/mnt/Encypted/Shared/Videos/ /home/mrgeotech/Videos/
    '';
#    pull-fs-exec = "${pull-fs}/bin/pull-fs";
in {
    # Make the actions user-runnable
    environment.systemPackages = with pkgs; [
        push-fs
        pull-fs
    ];

#    # Handle power cycling
#    systemd.services = {
#        "shared-fs" = {
#            description = "Pulls on start and pushes on stop";
#            wantedBy = [ "multi-user.target" ];
#            serviceConfig = {
#                User = "mrgeotech";
#                ExecStart = pull-fs-exec;
#                ExecStop = push-fs-exec;
#            };
#            path = with pkgs; [ rsync openssh ];
#        };
#    };
#
#    # Handle lid events
#    services.acpid.handlers = {
#        "pull-fs" = {
#            event = "button/lid.open";
#            action = pull-fs-exec;
#        };
#        "push-fs" = {
#            event = "button/lid.close";
#            action = push-fs-exec;
#        };
#    };
}
