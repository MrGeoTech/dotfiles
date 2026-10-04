# Living-room console: boots straight into Steam Big Picture and nothing else.
# Hardware: AMD Athlon II (AM3, DDR3), RTX 2070 SUPER, Xbox wireless dongle.
{
  pkgs,
  config,
  ...
}: let
  # cage runs this straight from systemd, not from a login shell, so pull in
  # the normal system environment (PATH and friends) before starting Steam.
  steamSession = pkgs.writeShellScript "steam-session" ''
    . /etc/profile
    exec steam -gamepadui
  '';
in {
  imports = [
    ./hardware-configuration.nix

    ../common/core
    ../common/optional/pipewire.nix
    ../common/optional/bluetooth.nix

    ../common/users/mrgeotech
  ];

  boot = {
    # LTS kernel (the NixOS default): the out-of-tree NVIDIA module tracks it
    # best, and a console has no use for the newest kernel features.
    kernelParams = ["quiet" "loglevel=3" "udev.log_level=3"];
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 15;
      };
      efi.canTouchEfiVariables = true;
      timeout = 1;
    };
  };

  # NetworkManager alone (from common/core). This used to also enable
  # systemd-networkd on the same wifi card; the two fighting over wlp5s0 is a
  # classic multi-minute "waiting for network" stall at boot.
  networking = {
    hostName = "steam-machine";
    # Wifi power saving trades latency spikes for battery this box doesn't have.
    networkmanager.wifi.powersave = false;
  };
  # Nothing here needs the network before Steam starts; Steam waits on its own.
  systemd.services.NetworkManager-wait-online.enable = false;

  # Old CPU: never wait for the governor to ramp up mid-game.
  powerManagement.cpuFreqGovernor = "performance";

  # Steam Big Picture in cage, a single-app Wayland compositor, autologged in
  # on tty1. Not gamescope: on NVIDIA its session mode corrupts Steam's
  # translucent UI (the button legend that appears with a controller) --
  # ValveSoftware/gamescope#1964 and #2309, both open. The same UI is clean
  # under wlroots, which cage is built on.
  #   -s  allow Ctrl+Alt+F2 to a text console for fixing things
  services.cage = {
    enable = true;
    user = "mrgeotech";
    program = steamSession;
    extraArguments = ["-s"];
  };
  # Quitting Steam (or a crash) drops back into Steam instead of a black screen.
  systemd.services.cage-tty1.serviceConfig = {
    Restart = "always";
    RestartSec = 2;
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    extraCompatPackages = [pkgs.proton-ge-bin];
  };

  # RTX 2070 SUPER (Turing): the open kernel module is NVIDIA's recommended
  # one from Turing on. The default driver is the 595 production branch,
  # which the gamescope reports above found better behaved than 610+.
  services.xserver.videoDrivers = ["nvidia"];
  hardware = {
    nvidia = {
      open = true;
      modesetting.enable = true;
    };
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    xone.enable = true; # Xbox wireless controller dongle
  };

  system.stateVersion = "26.05";
}
