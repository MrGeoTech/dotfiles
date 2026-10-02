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
    ../common/optional/virtualisation.nix
    (import ../common/optional/wireguard.nix {
      ip = "5";
    })

    # User config
    ../common/users/mrgeotech
  ];
  powerManagement.cpuFreqGovernor = "performance";
  powerManagement.enable = true;

  # Bootloader.
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

    # Lets nix build aarch64-linux derivations here via qemu emulation
    # instead of erroring with "platform mismatch" -- needed to build the
    # pi5 sd-image for the bison_pullers/panel flake from this x86_64 box.
    binfmt.emulatedSystems = [ "aarch64-linux" ];

    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      timeout = 1;
    };
  };

  # amd gpu support for kernel
  boot.initrd.kernelModules = ["amdgpu"];


  # Transparent zstd on root. Safe to add to an existing fs: only new
  # writes get compressed. Recompress old data with
  #   sudo btrfs filesystem defragment -r -czstd /
  fileSystems."/".options = [ "compress=zstd" "noatime" ];

  networking = {
    networkmanager = {
      wifi.powersave = false;
    };
    hostName = "mrgeotech-pc";
  };

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        #amdvlk 
        #driversi686Linux.amdvlk
        rocmPackages.clr
        rocmPackages.clr.icd
      ];
    };
    enableAllFirmware = true;
  };

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

  system.stateVersion = "26.05";
}
