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

    services.nginx = {
        enable = true;
        virtualHosts."www" = {
            root = "/var/www/";
        };
    };

    system.stateVersion = "24.05";
}
