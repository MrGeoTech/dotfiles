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
        ../common/optional/fonts.nix
        ../common/optional/hyprland.nix
        ../common/optional/pipewire.nix
        ../common/optional/steam.nix

        # User config
        ../common/users/mrgeotech
        ../common/users/mrgeotech/optional.nix
    ];

    # Bootloader (uses grub instead of systemd-boot)
    boot.kernelPackages = pkgs.linuxPackages_latest;
    boot.loader.grub = {
      enable = true;
      device = "/dev/sda";
      useOSProber = true;
      configurationLimit = 5;
    };

    networking = {
        networkmanager.wifi.powersave = true;
        hostName = "steam-machine";
        useNetworkd = true;
        interfaces.wlp5s0.useDHCP = true;
    };

    environment.systemPackages = with pkgs; [
        hyprpolkitagent
    ];

    security.polkit.enable = true;

    services = {
        printing.enable = true;

        blueman.enable = true;
        gnome.gnome-keyring.enable = true;

        udev.extraRules = ''
            SUBSYSTEM=="usb", ATTR{idVendor}=="09fb", ATTR{idProduct}=="6001", MODE="0666"
        '';

        displayManager.autoLogin = {
          enable = true;
          user = "mrgeotech";
        };
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
