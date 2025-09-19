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

    ./plymouth.nix

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
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader.grub = {
      enable = true;
      device = "/dev/sda";
      useOSProber = true;
      configurationLimit = 5;
    };
    kernelParams = [
      "quiet"
      "loglevel=3"
      "udev.log_level=3"
    ];
  };

  networking = {
    networkmanager.wifi.powersave = true;
    hostName = "steam-machine";
    useNetworkd = true;
    interfaces.wlp5s0.useDHCP = true;
  };

  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
      gamescopeSession.enable = true;
    };
    gamescope = {
      enable = true;
      capSysNice = true;
    };
    gamemode.enable = true;
  };
  hardware.xone.enable = true; # support for the xbox controller USB dongle

  # Load from display manager directly into steam gamemode
  environment = {
    systemPackages = with pkgs; [ mangohud ];
    loginShellInit = ''
      [[ "$(tty)" = "/dev/tty1" ]] && ./gamescope.sh
    '';
  };

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
      # Configure keymap in X11
      enable = true;
      videoDrivers = ["nvidia"];
      xkb.options = "ctrl:nocaps";
      xkb.layout = "us";
      xkb.variant = "";
      displayManager.lightdm.enable = true;
      #desktopManager.xfce = {
      #  enable = true;
      #  enableWaylandSession = true;
      #  enableScreensaver = false;
      #  noDesktop = false;
      #};
    };
  };

  # Load nvidia driver for Xorg and Wayland
  console.useXkbConfig = true;

  hardware = {
    nvidia = {
      open = true;
      modesetting.enable = true;
    };
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

  system.stateVersion = "24.05";
}
