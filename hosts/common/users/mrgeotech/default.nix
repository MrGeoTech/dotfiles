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
    age.keyFile = "/home/mrgeotech/.config/sops/age/keys.txt";

    # SSH identity used for server logins and GitHub auth (see
    # home/common/core/cli/ssh.nix for the client-side wiring). The
    # committed secrets/ssh.yaml is only a placeholder until it's replaced
    # with a real, locally-generated key -- see secrets/README.md.
    secrets."id_ed25519" = {
      sopsFile = ./secrets/ssh.yaml;
      path = "/home/mrgeotech/.ssh/id_ed25519";
      owner = "mrgeotech";
      mode = "0400";
    };
  };

  # Import this user's personal/home configurations
  home-manager.users.mrgeotech = import ../../../../home/${config.networking.hostName}.nix;
}
