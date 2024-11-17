# https://github.com/Alexays/Waybar
{pkgs, ...}: {
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    style = ./style.css;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        mod = "dock";
        margin-left = 0;
        margin-right = 0;
        margin-top = 0;
        margin-bottom = 0;
        reload_style_on_change = true;
        spacing = 0;
        modules-left = [
          "hyprland/workspaces"
          "hyprland/window"
        ];
        modules-center = [
          "clock"
        ];
        modules-right = [
          "pulseaudio"
          "network"
          "battery"
        ];

        "hyprland/workspaces" = {
          disable-scroll = false;
          all-outputs = false;
          active-only = false;
          format = "<span><b>{icon}</b></span>";
          format-icons = {
            "1" = "1";
            "2" = "2";
            "3" = "3";
            "4" = "4";
            "5" = "5";
            "6" = "6";
            "7" = "7";
            "8" = "8";
            "9" = "9";
            urgent = " ";
          };
        };
        "hyprland/window" = {
          max-length = 50;
          format = "<i> </i>";
          separate-outputs = false;
          icon = true;
          icon-size = 13;
        };

        # Module configuration: Center
        clock = {
          format = "{:%a, %b %d  %I:%M %p}";
	  tooltip = true;
          tooltip-format = "<tt><small>{calendar}</small></tt>";
        };

        # Module configuration: Right
        pulseaudio = {
          format = "{icon} {format_source}";
          format-bluetooth = "{icon} {format_source} ";
          format-bluetooth-muted = "{icon} {format_source} ";
          format-muted = "{icon} {format_source}";
          format-source = " ";
          format-source-muted = " ";
          format-icons = {
            headphone = " ";
            hands-free = " ";
            headset = " ";
            phone = " ";
            portable = " ";
            car = " ";
            default = [" " " " " "];
          };
          on-click = "pavucontrol";
        };
        network = {
          format-wifi = "{ipaddr} ({signalStrength}%)  ";
          format-ethernet = "{ipaddr}  ";
	  tooltip = true;
          tooltip-format = "{essid} ({gwaddr}) via {ifname}";
          format-linked = "<No IP>  ";
          format-disconnected = "Disconnected ⚠ ";
          format-alt = "{ifname}: {ipaddr}/{cidr}";
        };
        battery = {
          states = {
            # good = 95;
            warning = 30;
            critical = 15;
          };
          format = "{capacity}% {icon}";
          format-charging = "{capacity}%  ";
          format-plugged = "{capacity}%  ";
          format-alt = "{time} {icon}";
          format-icons = [" " " " " " " " " "];
        };
      };
    };
  };
}