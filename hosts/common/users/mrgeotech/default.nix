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
    extraGroups = ["networkmanager" "wheel"] ++ ifTheyExist ["docker" "libvirtd" "mysql" "network" "git"];
  };

  sops = {
    defaultSopsFile = ./secrets/wireless.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "home/mrgeotech/.config/sops/age/keys.txt";
  };
}
