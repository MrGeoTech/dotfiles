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
      ../common/optional/hyprland.nix
      ../common/optional/nfs.nix
      ../common/optional/steam.nix
      ../common/optional/wacom.nix

      # User config
      ../common/users/mrgeotech
    ]
    ++ (builtins.attrValues outputs.nixosModules);

  # Bootloader.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.grub.efiSupport = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.loader.systemd-boot.enable = true;
  boot.loader.grub.useOSProber = true;
  boot.loader.grub.configurationLimit = 15;
  boot.loader.systemd-boot.configurationLimit = 15;
  boot.supportedFilesystems = ["ntfs"];

  networking.hostName = "mrgeotech-laptop"; # Define your hostname.

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Load nvidia driver for Xorg and Wayland
  console.useXkbConfig = true;
  hardware.bluetooth.enable = true;
  networking.interfaces.wlp5s0.useDHCP = true;

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
