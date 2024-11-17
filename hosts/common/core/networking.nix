{
  networking = {
    networkmanager = {
      enable = true;
      wifi.powersave = true;
    };
    wireless.enable = false;
    nameservers = ["1.1.1.1"];
  };
}
