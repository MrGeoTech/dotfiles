{
  #programs.alvr = {
  #  enable = true;
  #  openFirewall = true;
  #};
  # Steam Frame wireless dongle (rtw89) refuses to work while the wifi
  # regulatory domain is unset ("country 00: DFS-UNSET"), so pin it.
  hardware.wirelessRegulatoryDatabase = true;
  boot.extraModprobeConfig = ''
    options cfg80211 ieee80211_regdom="US"
  '';

  programs.gamemode.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    gamescopeSession.enable = true;
  };
}
