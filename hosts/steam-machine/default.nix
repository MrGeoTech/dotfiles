{
  pkgs,
  config,
  inputs,
  outputs,
  ...
}: {
  imports = [
    # Hardware config
    ./hardware-configuration.nix

    # Common config
    ../common/core
      # Optional configs
    ../common/optional/fonts.nix
    ../common/optional/pipewire.nix

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

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    gamescopeSession.enable = true;
  };

  programs.gamemode.enable = true;

  security.polkit.enable = true;

  services = {
    printing.enable = true;

    blueman.enable = true;
    gnome.gnome-keyring.enable = true;

    udev.extraRules = ''
      SUBSYSTEM=="usb", ATTR{idVendor}=="09fb", ATTR{idProduct}=="6001", MODE="0666"
    '';

    getty.autologinUser = "mrgeotech";
    displayManager = {
      autoLogin = {
        enable = true;
        user = "mrgeotech";
      };
    };
    xserver = {
      displayManager.lightdm.enable = true;
      desktopManager.xfce = {
        enable = true;
        enableWaylandSession = true;
        enableScreenSaver = false;
        noDesktop = false;
      };
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

  hardware.nvidia.open = true;
  hardware.nvidia.modesetting.enable = true;

  system.stateVersion = "24.05";
}
