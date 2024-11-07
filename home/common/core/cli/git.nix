{
  programs.git = {
    enable = true;
    userEmail = "mrgeotech@mrgeotech.net";
    userName = "MrGeoTech";
    extraConfig = {
      core.editor = "nvim";
      init.defaultBranch = "master";
      merge.conflictStyle = "zdiff3";
      branch.sort = "committerdate";
      push.autoSetupRemote = true;
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
