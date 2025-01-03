{
    pkgs,
    outputs,
    inputs,
    config,
    ...
}: {
    imports = [
        # Hardware config
        inputs.hardware.nixosModules.common-cpu-amd
        ./hardware-configuration.nix

        # Common config
        ../common/core

        # User config
        ../common/users/mrgeotech

        # Webservice cofig
        ./nginx/isaacgeorge.net.nix
    ];

    # Bootloader.
    boot.kernelPackages = pkgs.linuxPackages_latest;
    boot.loader.grub = {
        device = "nodev";
        useOSProber = true;
        configurationLimit = 15;
    };

    networking.hostName = "www";
    # Enable http and ssh ports
    networking.firewall.allowedTCPPorts = [ 80 50293 ];

    # Enable ssh
    services.openssh = {
        enable = true;
        ports = [ 50293 ];
        settings = {
            PasswordAuthentication = true;
            AllowUsers = [ "mrgeotech" ];
            PermitRootLogin = "no";
        };
    };

    # Fail2Ban
    services.fail2ban = {
        enable = true;
        maxretry = 5;
        ignoreIP = [
            # Whitelist local subnets (for when I inevitably accidently "hack" myself)
            "10.0.0.0/8" "172.16.0.0/12" "192.168.0.0/16"
        ];
        bantime = "24h";
        bantime-increment = {
            enable = true;
            formula = "ban.Time * math.exp(float(ban.Count+1)*2)/math.exp(2)";
            maxtime = "168h";
            overalljails = true;
        };
        #jails = {};
    };

    system.stateVersion = "24.05";
}
