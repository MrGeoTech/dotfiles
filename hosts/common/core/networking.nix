{
  networking = {
    networkmanager = {
      enable = true;
      wifi.powersave = true;
    };
    useNetworkd = true;
    wireless.enable = false;
    nameservers = ["1.1.1.1"];
  };
}
