{...}: {
  programs.ssh = {
    enable = true;

    matchBlocks."*" = {
      # Default identity for every host: servers and GitHub alike. The
      # private key is decrypted via sops-nix, see
      # hosts/common/users/mrgeotech/default.nix.
      identityFile = "~/.ssh/id_ed25519";

      # Prefer post-quantum-hybrid key exchange so the transport resists
      # "harvest now, decrypt later" attacks, falling back to classical
      # algorithms for servers whose OpenSSH doesn't support the hybrid
      # ones yet. This only strengthens the KEX/transport -- OpenSSH has
      # no post-quantum *signature* algorithm yet, so the identity key
      # above stays classical (Ed25519) until one exists upstream and
      # GitHub accepts it.
      extraOptions.KexAlgorithms = "mlkem768x25519-sha256,sntrup761x25519-sha512@openssh.com,curve25519-sha256,diffie-hellman-group16-sha512";
    };
  };
}
