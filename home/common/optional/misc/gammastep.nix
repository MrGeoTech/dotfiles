{
  services.gammastep = {
    enable = true;
    provider = "manual";
    # Fargo, ND, USA
    latitude = 46.877186;
    longitude = -96.789803;
    temperature = {
      day = 6500;
      night = 4500;
    };
    settings = {
      general = {
        brightness-day = 1.0;
        brightness-night = 0.8;
      };
    };
    tray = true;
  };
}
