{
  # Disable waiting for network when booting to speed up boot significatly
  #systemd.services."NetworkManager-wait-online".enable = false;
  networking = {
    # Make sure wireless is disabled
    wireless.enable = false;
    # Configure NetworkManager
    networkmanager = {
      enable = true;
    };
    # Configure DNS servers
    # [ CLOUDFLARE, CLOUDFLARE_BACKUP, GOOGLE, GOOGLE_BACKUP ]
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
      "8.8.8.8"
      "8.8.4.4"
    ];
  };
}
