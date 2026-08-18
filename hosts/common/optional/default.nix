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
  
  services = {
    printing.enable = true;

    gnome.gnome-keyring.enable = true;

    udev.extraRules = ''
            SUBSYSTEM=="usb", ATTR{idVendor}=="09fb", ATTR{idProduct}=="6001", MODE="0666"
    '';
  };

  programs.gnome-disks.enable = true;
}
