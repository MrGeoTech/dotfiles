{ pkgs, ... }: {
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
    # SteamVR's vrwebhelper (CEF: settings, dashboard, pairing) exits 127
    # without these; `ldd` inside steam-run shows them missing from the FHS env.
    extraPackages = with pkgs; [
      at-spi2-core # libatk-1.0, libatk-bridge-2.0, libatspi
      nss # libnss3, libnssutil3, libsmime3
      nspr
      SDL2
      libxcomposite
      # SteamVR's restarthelper (used when toggling add-ons) is a Qt5 binary.
      libsForQt5.qtbase # libQt5Core, libQt5Gui, libQt5Widgets
    ];
  };
}
