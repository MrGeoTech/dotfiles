{
  pkgs,
  config,
  inputs,
  #catppuccin,
  ...
}: {
  imports = [
    #catppuccin.homeManagerModules.catppuccin
  ];

  users.users.mrgeotech = {
    packages = [pkgs.home-manager];
  };

  # Import this user's personal/home configurations
  home-manager.users.mrgeotech = import ../../../../home/${config.networking.hostName}.nix;

  systemd.services.flatpak-repo = {
    enable = true;
    description = "Flathub repo for flatpak";
    wantedBy = ["multi-user.target"];
    path = [pkgs.flatpak];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };

}
