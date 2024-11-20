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
      ./hardware-configuration.nix

      # Common config
      ../common/core

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

  networking.hostName = "wwww";

  system.stateVersion = "24.05";
}
