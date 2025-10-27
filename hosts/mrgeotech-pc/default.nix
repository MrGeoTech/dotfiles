{
  pkgs,
  outputs,
  inputs,
  ...
}: {
  imports = [
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
      #amdvlk 
      #driversi686Linux.amdvlk
      rocmPackages.clr
      rocmPackages.clr.icd
    ];
  };
  hardware.enableAllFirmware = true;

  # Load amd driver for Xorg and Wayland
  services.xserver.videoDrivers = ["amdgpu"];
  console.useXkbConfig = true;

  # Configure keymap in X11
  services.xserver = {
    enable = false;
    xkb.options = "ctrl:nocaps";
    xkb.layout = "us";
    xkb.variant = "";
  };

  system.stateVersion = "24.05";
}
