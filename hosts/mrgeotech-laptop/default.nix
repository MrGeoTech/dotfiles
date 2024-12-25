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

    firewall.allowedUDPPorts = [ 29566 ];
    wireguard.interfaces.wg0 = {
        ips = [ "10.0.0.2/24" ];
        listenPort = 29566;

        privateKeyFile = "/home/mrgeotech/.wireguard/private_key";

        peers = [
            {
                publicKey = "BHC4Qu12Hbk1eYxwnUoYDDGB28JGsrmhu5FaNlgD0go=";
                # Only forward vpn subnet through vpn
                allowedIPs = [ "10.0.0.0/24" ];

                endpoint = "mrgeotech.net:29566";

                persistentKeepalive = 25;
            }
        ];
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
  environment.systemPackages = [
    (pkgs.catppuccin-sddm.override {
      flavor = "mocha";
      font  = "Iosevka NF";
      fontSize = "15";
      #background = "${./wallpaper.png}";
      loginBackground = true;
    })
    pkgs.brightnessctl
  ];
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
