{
  inputs,
  outputs,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./catppuccin.nix
    ./gnupg.nix
    ./locale.nix
    ./networking.nix
    ./nix.nix
    ./nh.nix
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
    openssh = {
      enable = true;
      # Only the id_ed25519 key trusted in each user's authorizedKeys can
      # log in -- no password/keyboard-interactive fallback, so a stolen
      # password can't be used to reach any of these machines over ssh.
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };

    devmon.enable = true;
    gvfs.enable = true;
    udisks2.enable = true;

    dbus.enable = true;
  };

  hardware.enableRedistributableFirmware = true;
}
