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
    ];

    # Bootloader
    boot = {
      kernelPackages = pkgs.linuxPackages_latest;
    
      loader = {
        systemd-boot = {
          enable = true;
          configurationLimit = 15;
        };
        efi = {
          canTouchEfiVariables = true;
          efiSysMountPoint = "/boot";
        };
        timeout = 1;
      };
    };

    networking = {
        networkmanager.wifi.powersave = true;
        hostName = "mrgeotech-zenbook";
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
    environment.systemPackages = [
        pkgs.brightnessctl
    ];

    services.logind.settings.Login = {
      HandlePowerKey = false;
    };

    system.stateVersion = "24.11";
}
