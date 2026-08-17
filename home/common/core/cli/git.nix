{pkgs, ...} : {
  programs.git = {
    enable = true;
    settings = {
      user = {
        email = "git-mail@isaacgeorge.net";
        name = "Isaac George";
      };
      core.editor = "nvim";
      init.defaultBranch = "master";
      merge.conflictStyle = "zdiff3";
      branch.sort = "committerdate";
      push.autoSetupRemote = true;

      #sendmail = {
      #    from = "Isaac George <git-mail@isaacgeorge.net>";
      #    smtpServer = "127.0.0.1";
      #    smtpServerPort = 1025;
      #    smtpUser = "mrgeotech";
      #    smtpPassword = "/HxMou3HXfi+RaEAxry8w6Ws0tybPdVPHJxpSNvAC0I="; # This is a localhost only password so should be fine
      #};
    };
    signing = {
      # Reuses the sops-managed SSH identity (see
      # hosts/common/users/mrgeotech/default.nix) instead of a separate GPG
      # key. Signs directly with the private key file rather than going
      # through ssh-agent, since nothing here loads this key into one.
      format = "ssh";
      key = "/home/mrgeotech/.ssh/id_ed25519";
      signer = "${pkgs.openssh}/bin/ssh-keygen";
      signByDefault = true;
    };
    lfs.enable = true;
    ignores = [
      ".direnv/"
        ".devenv/"
        ".venv/"
        ".env"
    ];
  };
  home.packages = with pkgs; [
    git-extras
  ];
}
