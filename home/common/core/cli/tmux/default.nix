{pkgs, ...}: {
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    keyMode = "vi";
    mouse = true;
    terminal = "tmux-256color";

    extraConfig = ''
      # https://github.com/srid/nixos-config/blob/master/modules/home/all/tmux.nix
      # https://old.reddit.com/r/tmux/comments/mesrci/tmux_2_doesnt_seem_to_use_256_colors/
      set -g default-terminal "xterm-256color"
      set -ga terminal-overrides ",*256col*:Tc"
      set -ga terminal-overrides '*:Ss=\E[%p1%d q:Se=\E[ q'
      set-environment -g COLORTERM "truecolor"

      # reload config
      bind r source-file ~/.config/tmux/tmux.conf

      # Configure the catppuccin plugin
      set -g @catppuccin_flavor "mocha"
      set -g @catppuccin_window_status_style "rounded"
      
      # Load catppuccin
      run-shell ${pkgs.tmuxPlugins.catppuccin}/share/tmux-plugins/catppuccin/catppuccin.tmux
      
      # Make the status line pretty and add some modules
      set -g status-right-length 100
      set -g status-left-length 100
      set -g status-left ""
      set -g status-right "#{E:@catppuccin_status_application}"
      set -agF status-right "#{E:@catppuccin_status_cpu}"
      set -ag status-right "#{E:@catppuccin_status_session}"
      set -ag status-right "#{E:@catppuccin_status_uptime}"
      set -agF status-right "#{E:@catppuccin_status_battery}"
      
      run-shell ${pkgs.tmuxPlugins.battery}/share/tmux-plugins/battery/battery.tmux
      run-shell ${pkgs.tmuxPlugins.cpu}/share/tmux-plugins/cpu/cpu.tmux
    '';
  };

  # aliases
  home.shellAliases = {
    tn = "tmux new -s";
    ta = "tmux attach -t";
    td = "tmux detach";
    tk = "tmux kill-session -t";
    tl = "tmux ls";
  };
}
# # Configure the catppuccin plugin
# set -g @catppuccin_flavor "mocha"
# set -g @catppuccin_window_status_style "slanted"
# set -ogq @catppuccin_status_left_separator ""
# set -g @catppuccin_cpu_icon "⚡"
# set -g @catppuccin_weather_icon "☀ "
#
# # Configure weather plugin
# set -g @tmux-weather-units "u"
# set -g @tmux-weather-location "Fargo"
# 
# # Make the status line pretty and add some modules
# set -g status-right-length 100
# set -g status-left-length 100
# set -g status-left ""
# set -gF status-right "#{E:@catppuccin_status_cpu}#{E:@catppuccin_status_weather}#{@catppuccin_status_gitmux}"
# 
# # Load plugins
# run-shell ${pkgs.tmuxPlugins.battery}/share/tmux-plugins/battery/battery.tmux
# run-shell ${pkgs.tmuxPlugins.cpu}/share/tmux-plugins/cpu/cpu.tmux
# run-shell ${pkgs.tmuxPlugins.weather}/share/tmux-plugins/weather/tmux-weather.tmux
# run-shell ${pkgs.tmuxPlugins.catppuccin}/share/tmux-plugins/catppuccin/catppuccin.tmux
