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
    extraGroups = ["networkmanager" "wheel" "dialout"] ++ ifTheyExist ["wireshark" "docker" "libvirtd" "mysql" "network" "git"];
    packages = [pkgs.home-manager];
  };

  sops = {
    defaultSopsFile = ./secrets/wireless.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "home/mrgeotech/.config/sops/age/keys.txt";
  };

  # Import this user's personal/home configurations
  home-manager.users.mrgeotech = import ../../../../home/${config.networking.hostName}.nix;
}
