{
  networking = {
    # Configure NetworkManager
    networkmanager = {
      enable = true;
      dhcp = "internal";
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
