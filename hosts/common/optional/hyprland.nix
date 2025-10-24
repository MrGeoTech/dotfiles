{pkgs, lib, ...}: {
  # Login setup
  programs.uwsm.enable = true;
  services.getty.autologinUser = "mrgeotech";

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  security.pam.services.hyprlock = {};
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-hyprland
    ];
  };

  environment.systemPackages = with pkgs; [ hyprpolkitagent ];
}
