{
    pkgs,
    outputs,
    inputs,
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
    ];

    # Bootloader.
    boot.kernelPackages = pkgs.linuxPackages_latest;
    boot.loader.grub = {
        device = "nodev";
        useOSProber = true;
        configurationLimit = 15;
    };

    networking.hostName = "www";
    networking.firewall.allowedTCPPorts = [ 80 ];

    services.nginx = {
        enable = true;
        virtualHosts."www" = {
            root = "/var/www/";
        };
    };
    services.phpfpm.pools.mypool = {
        user = "nobody";
        settings = {
            "pm" = "dynamic";
            "listen.owner" = config.services.nginx.user;
            "pm.max_children" = 5;
            "pm.start_servers" = 2;
            "pm.min_spare_servers" = 1;
            "pm.max_spare_servers" = 3;
            "pm.max_requests" = 500;
        };
    };
    system.stateVersion = "24.05";
}
