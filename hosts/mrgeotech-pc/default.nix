{
    pkgs,
    outputs,
    inputs,
    ...
}: {
    imports =
    [
        # Hardware config
        inputs.hardware.nixosModules.common-cpu-amd
        inputs.hardware.nixosModules.common-gpu-amd
        ./hardware-configuration.nix

        # Common config
        ../common/core

        # Optional configs
        ../common/optional
        (import ../common/optional/wireguard.nix {
            ip = "5";
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

    # amd gpu support for kernel
    boot.initrd.kernelModules = ["amdgpu"];

    networking.hostName = "mrgeotech-pc";
    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = true;

    hardware.graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [
            rocmPackages.clr
            rocmPackages.clr.icd
        ];
    };
    hardware.enableAllFirmware = true;

    # Setup to work with monitor

    environment.etc."firmware/edid/g9.bin".source = pkgs.fetchurl {
        url = "https://gitlab.freedesktop.org/drm/amd/uploads/f6de8a51fd064fc6929325aeb0467ca4/MYEDID";
        sha256 = "1bkacdxf1n5w3g33b4mdgrvz6j9xwka5jn0jzy590hpk9x4iaapc";
    };
    boot.kernelParams = [ "drm.edid_firmware=DP-2:edid/g9.bin" ];

    # Load amd driver for Xorg and Wayland
    services.xserver.videoDrivers = ["amdgpu"];
    console.useXkbConfig = true;

    # Configure keymap in X11
    services.xserver = {
        enable = true;
        xkb.options = "ctrl:nocaps";
        xkb.layout = "us";
        xkb.variant = "";
    };
    environment.systemPackages = [(
            pkgs.catppuccin-sddm.override {
            flavor = "mocha";
            font  = "Iosevka";
            fontSize = "15";
#background = "${./wallpaper.png}";
            loginBackground = true;
            }
            )];
    services.displayManager.sddm = {
        enable = true;
        wayland.enable = true;
        autoNumlock = true;

        theme = "catppuccin-mocha";
        package = pkgs.kdePackages.sddm;
    };

    system.stateVersion = "24.05";
}
