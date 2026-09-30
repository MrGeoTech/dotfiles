{
pkgs,
config,
inputs,
outputs,
...
}: {
  imports = [
    # Hardware config
    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-gpu-intel
    ./hardware-configuration.nix

    # Common config
    ../common/core

    # Optional configs
    ../common/optional
    ../common/optional/virtualisation.nix
    (import ../common/optional/wireguard.nix {
      ip = "3";
    })

    # User config
    ../common/users/mrgeotech
  ];

  # Bootloader
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

    # Lets nix build aarch64-linux derivations here via qemu emulation
    # instead of erroring with "platform mismatch" -- needed to build the
    # pi5 sd-image for the bison_pullers/panel flake from this x86_64 box.
    binfmt.emulatedSystems = [ "aarch64-linux" ];

    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 15;
      };
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      timeout = 1;
    };
  };

  # Transparent zstd on root. Safe to add to an existing fs: only new
  # writes get compressed. Recompress old data with
  #   sudo btrfs filesystem defragment -r -czstd /
  fileSystems."/".options = [ "compress=zstd" "noatime" ];

  networking = {
    networkmanager.wifi.powersave = true;
    hostName = "mrgeotech-zenbook";
  };

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        intel-media-driver
      ];
    };
  };

  console.useXkbConfig = true;

  # Configure keymap in X11
  environment.systemPackages = [
    pkgs.brightnessctl
  ];

  # Battery/thermals. ppd drives intel_pstate EPP and the ASUS
  # platform_profile; thermald keeps Meteor Lake from cooking itself.
  services.power-profiles-daemon.enable = true;
  services.thermald.enable = true;

  services.logind.settings.Login = {
    HandlePowerKey = false;
  };

  system.stateVersion = "26.05";
}
