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
      restartUnits = ["ssh-id-ed25519-pubkey.service"];
    };
  };

  # Derives ~/.ssh/id_ed25519.pub from the sops-managed private key on every
  # activation, and again whenever the private key content changes. Without
  # this, a stale .pub left over from a previous key silently wins: OpenSSH
  # prefers reading a companion .pub file over deriving one from the private
  # key, so a mismatched sibling breaks pubkey auth in a confusing way.
  systemd.services."ssh-id-ed25519-pubkey" = {
    description = "Derive ~/.ssh/id_ed25519.pub from the sops-managed private key";
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      User = "mrgeotech";
      ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.openssh}/bin/ssh-keygen -y -f /home/mrgeotech/.ssh/id_ed25519 > /home/mrgeotech/.ssh/id_ed25519.pub'";
    };
  };

  # Import this user's personal/home configurations
  home-manager.users.mrgeotech = import ../../../../home/${config.networking.hostName}.nix;
}
