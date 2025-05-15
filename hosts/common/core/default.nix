{
    inputs,
    outputs,
    ...
}: {
    imports = [
        inputs.home-manager.nixosModules.home-manager
        ./gnupg.nix
        ./locale.nix
        ./networking.nix
        ./nix.nix
        ./zsh.nix
    ];

    nixpkgs = {
        config = {
            allowUnfree = true;
            permittedInsecurePackages = [
                #"electron-28.3.3"
                #"electron-27.3.11"
                #"electron-25.9.0"
                #"electron-24.8.6"
                #"electron-22.3.27"
                #"zotero-6.0.27"
            ];
        };
    };

    services = {
        openssh.enable = true;

        devmon.enable = true;
        gvfs.enable = true;
        udisks2.enable = true;

        dbus.enable = true;
    };

    hardware.enableRedistributableFirmware = true;
}
