{ config, pkgs, ... }:

let
  wallpaperDir = "/home/mrgeotech/.config/hypr";
  setWallpaper = wallpaper: ''
    #!/bin/bash

    # Function to check if the user is logged in
    is_user_logged_in() {
        who | grep -q "^mrgeotech "
    }
    
    # Function to check if Hyprland is running
    is_hyprland_running() {
        pgrep "Hyprland" > /dev/null
    }
    
    # Wait until the user is logged in
    while ! is_user_logged_in; do
        sleep 2
    done
    
    while ! is_hyprland_running; do
        sleep 2
    done
    
    hyprctl hyprpaper wallpaper ",${wallpaperDir}/${wallpaper}"
  '';
in
{
  systemd.services = {
    setWallpaperMorning = {
      description = "Set Hyprpaper wallpaper to tropic_island_morning.jpg";
      serviceConfig.ExecStart = "${pkgs.bash}/bin/bash -c ${setWallpaper "tropic_island_morning.jpg"}";
    };
    setWallpaperDay = {
      description = "Set Hyprpaper wallpaper to tropic_island_day.jpg";
      serviceConfig.ExecStart = "${pkgs.bash}/bin/bash -c ${setWallpaper "tropic_island_day.jpg"}";
    };
    setWallpaperEvening = {
      description = "Set Hyprpaper wallpaper to tropic_island_evening.jpg";
      serviceConfig.ExecStart = "${pkgs.bash}/bin/bash -c ${setWallpaper "tropic_island_evening.jpg"}";
    };
    setWallpaperNight = {
      description = "Set Hyprpaper wallpaper to tropic_island_night.jpg";
      serviceConfig.ExecStart = "${pkgs.bash}/bin/bash -c ${setWallpaper "tropic_island_night.jpg"}";
    };
  };

  systemd.timers = {
    setWallpaperMorning = {
      description = "Set morning wallpaper at 7:00 AM";
      timerConfig = {
        OnCalendar = "07:00";
        Persistent = true;
      };
      wantedBy = [ "timers.target" ];
    };
    setWallpaperDay = {
      description = "Set day wallpaper at 11:00 AM";
      timerConfig = {
        OnCalendar = "11:00";
        Persistent = true;
      };
      wantedBy = [ "timers.target" ];
    };
    setWallpaperEvening = {
      description = "Set evening wallpaper at 5:00 PM";
      timerConfig = {
        OnCalendar = "17:00";
        Persistent = true;
      };
      wantedBy = [ "timers.target" ];
    };
    setWallpaperNight = {
      description = "Set night wallpaper at 7:00 PM";
      timerConfig = {
        OnCalendar = "19:00";
        Persistent = true;
      };
      wantedBy = [ "timers.target" ];
    };
  };
}
