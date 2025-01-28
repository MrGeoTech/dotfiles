{
    pkgs,
    config,
    inputs,
    outputs,
    ...
}: {
    imports = [
        # Hardware config
        inputs.hardware.nixosModules.common-cpu-intel
        inputs.hardware.nixosModules.common-gpu-intel
        ./hardware-configuration.nix

        # Common config
        ../common/core

        # Optional configs
        ../common/optional
        (import ../common/optional/wireguard.nix {
            ip = "3";
        })

        # User config
        ../common/users/mrgeotech
        ../common/users/mrgeotech/optional.nix
    ];

    # Bootloader.
    boot.kernelPackages = pkgs.linuxPackages_latest;
    boot.loader.grub.efiSupport = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.efi.efiSysMountPoint = "/boot";
    boot.loader.systemd-boot.enable = true;
    boot.loader.grub.useOSProber = true;
    boot.loader.grub.configurationLimit = 15;
    boot.loader.systemd-boot.configurationLimit = 15;

    networking = {
        networkmanager.wifi.powersave = true;
        hostName = "mrgeotech-zenbook";
        useNetworkd = true;
        interfaces.wlo1.useDHCP = true;
    };

    hardware.graphics = {
        enable = true;
        enable32Bit = true;
    };

    # Load nvidia driver for Xorg and Wayland
    console.useXkbConfig = true;
    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = true;

    # Configure keymap in X11
    services.xserver = {
        enable = true;
        videoDrivers = ["modesetting"];
        xkb.options = "ctrl:nocaps";
        xkb.layout = "us";
        xkb.variant = "";
    };
    environment.systemPackages = [
        pkgs.brightnessctl
    ];

    services.logind.extraConfig = ''
        # don’t shutdown when power button is short-pressed
        HandlePowerKey=ignore
    '';

    system.stateVersion = "24.11";
}
