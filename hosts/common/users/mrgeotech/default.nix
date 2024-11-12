{
  pkgs,
  config,
  inputs,
  ...
}: let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];
  users.users.mrgeotech = {
    isNormalUser = true;
    description = "Isaac George";
    shell = pkgs.zsh;
    extraGroups = ["networkmanager" "wheel"] ++ ifTheyExist ["podman" "docker" "libvirtd" "mysql" "network" "git"];
    packages = [pkgs.home-manager];
  };

  # Import this user's personal/home configurations
  home-manager.users.mrgeotech = import ../../../../home/${config.networking.hostName}.nix;

  sops = {
    defaultSopsFile = ./secrets/wireless.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "home/mrgeotech/.config/sops/age/keys.txt";
  };

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
