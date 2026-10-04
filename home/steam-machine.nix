{config, ...}: {
  # No desktop here (see hosts/steam-machine), so just the shell setup for
  # Ctrl+Alt+F2 / ssh and the gaming bits.
  imports = [
    ./common/core
    ./common/optional/apps/gaming.nix
    ./common/optional/apps/gpg.nix
  ];

  home = {
    username = "mrgeotech";
    homeDirectory = "/home/${config.home.username}";
    stateVersion = "24.11";
  };
}
