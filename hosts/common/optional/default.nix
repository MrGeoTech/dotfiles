{
  inputs,
  outputs,
  pkgs,
  ...
}: {
  imports = [
    ./bluetooth.nix
    ./flatpak.nix
    ./hyprland.nix
    ./keychron.nix
    ./pipewire.nix
    ./steam.nix
    ./labrador.nix
  ];

  environment.systemPackages = with pkgs; [
    gparted
    rpi-imager
  ];

  security.polkit.enable = true;

  fonts.fontDir.enable = true;
  
  # Compressed swap in RAM. Cheap insurance on the 16G zenbook and the
  # swapless pc; disk swap (if any) stays as lower-priority fallback.
  zramSwap.enable = true;

  services = {
    printing.enable = true;

    # Firmware updates from LVFS: `fwupdmgr refresh && fwupdmgr update`.
    fwupd.enable = true;

    gnome.gnome-keyring.enable = true;

    udev.extraRules = ''
            SUBSYSTEM=="usb", ATTR{idVendor}=="09fb", ATTR{idProduct}=="6001", MODE="0666"
    '';
  };

  programs.gnome-disks.enable = true;
}
