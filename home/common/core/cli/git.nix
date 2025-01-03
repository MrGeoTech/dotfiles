{
    programs.git = {
        enable = true;
        userEmail = "git-mail@isaacgeorge.net";
        userName = "Isaac George";
        extraConfig = {
            core.editor = "nvim";
            init.defaultBranch = "master";
            merge.conflictStyle = "zdiff3";
            branch.sort = "committerdate";
            push.autoSetupRemote = true;

            sendmail = {
                from = "Isaac George <git-mail@isaacgeorge.net>";
                smtpServer = "127.0.0.1";
                smtpServerPort = 1025;
                smtpUser = "mrgeotech";
                smtpPassword = "/HxMou3HXfi+RaEAxry8w6Ws0tybPdVPHJxpSNvAC0I="; # This is a localhost only password so should be fine
            };
        };
        lfs.enable = true;
        ignores = [
            ".direnv/"
            ".devenv/"
            ".venv/"
            ".env"
        ];
    };
}
