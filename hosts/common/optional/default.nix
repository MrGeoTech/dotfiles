{
    inputs,
    outputs,
    pkgs,
    ...
}: {
    imports = [
        ./docker.nix
        ./fonts.nix
        ./pipewire.nix
        ./hyprland.nix
        ./sddm.nix
        ./steam.nix
        ./sound.nix
        ./shared.nix
        ./virt-manager.nix
        ./wireshark.nix
    ];

    environment.systemPackages = with pkgs; [
        hyprpolkitagent
        gparted
    ];

    security.polkit.enable = true;

    services = {
        printing.enable = true;

        blueman.enable = true;
        gnome.gnome-keyring.enable = true;

        flatpak.enable = true;

        udev.extraRules = ''
            SUBSYSTEM=="usb", ATTR{idVendor}=="09fb", ATTR{idProduct}=="6001", MODE="0666"
        '';
    };

    programs.gnome-disks.enable = true;
}
