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
    hostName = "mrgeotech-laptop";
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
  environment.systemPackages = [(
    pkgs.catppuccin-sddm.override {
      flavor = "mocha";
      font  = "Iosevka NF";
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
