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
