{
    inputs,
    outputs,
    pkgs,
    ...
}: {
    imports = [
        ./fonts.nix
        ./hyprland.nix
        ./pipewire.nix
        #./shared.nix
        ./steam.nix
        ./virtualisation.nix
        ./labrador.nix
        #./wireshark.nix
    ];

    environment.systemPackages = with pkgs; [
        gparted
        rpi-imager
    ];

    security.polkit.enable = true;

    services = {
        printing.enable = true;

        blueman.enable = true;
        gnome.gnome-keyring.enable = true;

        udev.extraRules = ''
            SUBSYSTEM=="usb", ATTR{idVendor}=="09fb", ATTR{idProduct}=="6001", MODE="0666"
        '';
    };

    programs.gnome-disks.enable = true;
}
