{
    hostName,
        pkgs,
        ...
}: let
    monitorConfig =
        if hostName == "mrgeotech-pc" then [
            "DP-2,highres,0x0,1"
            "HDMI-A-1,highres,5120x0,1"
        ] else [
            ",highres,auto,1"
        ];

    kbOptions = "caps:escape";
in {
    wayland.windowManager.hyprland = {
        enable = true;
        systemd.enable = true;
        xwayland.enable = true;
        sourceFirst = true;
        settings = {
            source = [
                "~/.config/hypr/mocha.conf" # Theme
            ];
            monitor = monitorConfig;
            exec-once = [
                "hyprpaper"
                #"hyprctl setcursor  24"
                "systemctl --user start hyprpolkitagent"
                "sh /home/mrgeotech/.config/hypr/scripts/wallpaper.sh"
            ];
            env = [
                "XCURSOR_SIZE,24"
                "WLR_DRM_DEVICES,/dev/dri/card0:/dev/dri/card1"
            ];
            input = {
                kb_layout = "us";
                kb_variant = "";
                kb_model = "";
                kb_rules = "";
                kb_options = kbOptions;
                numlock_by_default = true;
                natural_scroll = false;
                follow_mouse = 1;
                touchpad = {
                    natural_scroll = true;
                };
                sensitivity = if hostName == "mrgeotech-zenbook" then 0.5 else 1;
            };
            general = {
                gaps_in = 0;
                gaps_out = 0;
                border_size = 0;
                "col.active_border" = "$mauve";
                "col.inactive_border" = "$surface0";
                layout = "dwindle";
            };
            group = {
                "col.border_active" = "$mauve";
                "col.border_inactive" = "$surface0";
                groupbar = {
                    font_family = "IosevkaTerm";
                    font_size = if hostName == "mrgeotech-zenbook" then 18 else 12;
                    gradients = true;
                    text_color = "$crust";
                    "col.active" = "$mauve";
                    "col.inactive" = "$overlay0";
                };
            };
            decoration = {
                rounding = 0;
                active_opacity = 1.0;
                #inactive_opacity = 0.85;
                dim_inactive = true;
                dim_strength = 0.1;
                blur = {
                    enabled = true;
                    size = 8;
                    passes = 2;
                    popups = true;
                };
            };
            binds = {
                movefocus_cycles_fullscreen = false;
                workspace_center_on = 1;
                focus_preferred_method = 0;
            };
            dwindle = {
                pseudotile = false;
                force_split = 0;
                default_split_ratio = 1.0;
            };
            master = {
                new_status = "slave";
            };
            gestures = {
                workspace_swipe = true;
            };
            misc = {
                disable_hyprland_logo = true;
                mouse_move_enables_dpms = true;
                key_press_enables_dpms = true;
            };
            # Window rules
            windowrulev2 = [
                "dimaround,title:^(.*rofi.*)$"
                "noblur,focus:1"
            ];
            # Animations
            animation = "global, 1, 3, default";
            # Keybindings
            "$mainMod" = "SUPER";
            "$subMod" = "SUPER_SHIFT";
            "$tetMod" = "SUPER_CTRL";
            bind = [
                "$mainMod, SUPER_L, exec, rofi -show run"
                "$mainMod, T, exec, ghostty"
                "$mainMod, B, exec, $BROWSER"
                "$mainMod, F, exec, ghostty -e yazi"
                "$mainMod, G, exec, steam"
                "$mainMod, Q, killactive,"
                "$subMod , Q, forcekillactive,"
                "$mainMod, E, exit,"
                "$subMod , E, exec, shutdown now"
                "$subMod , R, exec, reboot"
                "$mainMod, W, exec, pkill waybar && waybar"
                "$mainMod, S, togglesplit,"
                "$subMod , SPACE, exec, rofi -show window"
                "$subMod , S, exec, rofi -show ssh"
                "        , PRINT, exec, ~/.config/hypr/scripts/screenshot.sh region"
                "$mainMod, PRINT, exec, ~/.config/hypr/scripts/screenshot.sh activemonitor"
                "$subMod , PRINT, exec, ~/.config/hypr/scripts/screenshot.sh activewindow"
                # Move focus with mainMod + arrow keys
                "$mainMod, RIGHT, movefocus, r"
                "$mainMod, LEFT, movefocus, l"
                "$mainMod, UP, movefocus, u"
                "$mainMod, DOWN, movefocus, d"
                # Groups
                "$tetMod , G, togglegroup"
                "$tetMod , H, moveintogroup, l"
                "$tetMod , L, moveintogroup, r"
                "$tetMod , K, moveintogroup, u"
                "$tetMod , J, moveintogroup, d"
                "$tetMod , N, changegroupactive, f"
                "$tetMod , P, changegroupactive, b"
                # Move to next/previous workspace with mainMod + ['<','>']
                "$mainMod, COMMA, workspace, r-1"
                "$mainMod, PERIOD, workspace, r+1"
                # Move window to next/previous workspace with submod + ['<','>']
                "$subMod , COMMA, movetoworkspace, r-1"
                "$subMod , PERIOD, movetoworkspace, r+1"
                # Resize windows with subMod + h,j,k,l
                "$subMod , RIGHT, movewindow, r"
                "$subMod , LEFT, movewindow, l"
                "$subMod , UP, movewindow, u"
                "$subMod , DOWN, movewindow, d"
                # Scroll through existing workspaces with mainMod + scroll
                # TODO: Fix
                "$mainMod, MOUSE_UP, workspace, r+1"
                "$mainMod, MOUSE_DOWN, workspace, r-1"
                # Layout toggles
                "$subMod , F, fullscreen, 0"
                "$subMod , M, fullscreen, 1"
                "$tetMod , F, togglefloating"
                # Brightness control
                "        , XF86MonBrightnessUp, exec, brightnessctl set +10%"
                "        , XF86MonBrightnessDown, exec, brightnessctl set 10%-"
#                "$tetMod , 1, movecurrentworkspacetomonitor, HDMI-A-1"
#                "$tetMod , 2, movecurrentworkspacetomonitor, DP-1"
#                "$tetMod , 3, movecurrentworkspacetomonitor, DP-2"
            ] ++ (
                # Switch workspaces with mainMod + [0-9]
                # Move active window to a workspace with subMod + [0-9]
                builtins.concatLists (builtins.genList (
                    i: let ws = i + 1;
                    in [
                        "$mainMod, code:1${toString i}, workspace, ${toString ws}"
                        "$subMod, code:1${toString i}, movetoworkspace, ${toString ws}"
                    ]
                )9)
            );
            bindm = [
                # Move/resize windows with mainMod + LMB/RMB and dragging
                "$mainMod, mouse:272, movewindow"
                "$mainMod, mouse:273, resizewindow"
            ];
        };
    };
}
