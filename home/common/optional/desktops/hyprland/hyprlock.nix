# hyprlock still uses hyprlang -- the Lua switch is Hyprland-only for now, so
# this file (and hypridle/hyprpaper) stays exactly as it was, apart from
# pulling colors from the shared palette.
let
  c = import ./colors.nix;
in {
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        hide_cursor = true;
        ignore_empty_input = true;
      };

      background = [
        {
          path = "screenshot";
          blur_passes = 3;
          blur_size = 8;
          contrast = 0.8916;
          brightness = 0.8;
          vibrancy = 0.1696;
          vibrancy_darkness = 0.0;
        }
      ];

      input-field = [
        {
          size = "400, 50";
          halign = "center";
          valign = "center";
          position = "0, -80";
          monitor = "";
          dots_center = true;
          fade_on_empty = false;
          hide_input = false;
          font_family = "Iosevka";
          font_color = c.text;
          inner_color = c.base;
          outer_color = c.mauve;
          outline_thickness = 1;
          placeholder_text = "<i>Password...</i>";
          shadow_passes = 2;
          check_color = c.green;
          fail_color = c.red;
          fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
          fail_timeout = 2000;
          fail_transition = 300;
        }
      ];
    };
  };
}
