{
  networking = {
    networkmanager = {
      enable = true;
      wifi.powersave = true;
    };
    useNetworkd = true;
    interfaces.wlp5s0.useDHCP = true;
    wireless.enable = false;
    nameservers = ["1.1.1.1"];
  };
}
