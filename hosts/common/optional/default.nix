{
  inputs,
  outputs,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./docker.nix
    ./fonts.nix
    ./pipewire.nix
    ./hyprland.nix
    ./steam.nix
    ./shared.nix
  ];

  services = {
    printing.enable = true;

    blueman.enable = true;
    gnome.gnome-keyring.enable = true;

    flatpak.enable = true;
  };

  programs.gnome-disks.enable = true;
}
