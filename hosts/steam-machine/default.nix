{
    pkgs,
    config,
    inputs,
    outputs,
    ...
}: {
    imports =
        [
        # Hardware config
        inputs.hardware.nixosModules.common-cpu-amd
        inputs.hardware.nixosModules.common-gpu-nvidia
        ./hardware-configuration.nix

        # Common config
        ../common/core

        # Optional configs
        ../common/optional

        # User config
        ../common/users/mrgeotech
        ../common/users/mrgeotech/optional.nix
    ];

    # Bootloader
    boot.kernelPackages = pkgs.linuxPackages_latest;
    boot.loader = {
      grub = {
        enable = true;
        device = "/dev/sda";
        efiSupport = true;
        useOSProber = true;
        configurationLimit = 5;
      };
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };
    };

    networking = {
        networkmanager.wifi.powersave = true;
        hostName = "steam-machine";
        useNetworkd = true;
        interfaces.wlp5s0.useDHCP = true;
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
        videoDrivers = ["nvidia"];
        xkb.options = "ctrl:nocaps";
        xkb.layout = "us";
        xkb.variant = "";
    };

    hardware.nvidia = {
        modesetting.enable = true;
        powerManagement.enable = true;
        powerManagement.finegrained = false;
        open = true;
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.stable;
        prime = {
            intelBusId = "PCI:0:02:0";
            nvidiaBusId = "PCI:1:00:0";
        };
    };

    system.stateVersion = "24.05";
}
