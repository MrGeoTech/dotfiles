{hostName, pkgs, ...}: {
  programs.kitty = {
    enable = true;
    font = {
      name = "IosevkaTerm";
      size = if hostName == "mrgeotech-zenbook" then 18 else 12;
    };
    settings = {
      window_padding_width = 0;
      window_padding_height = 0;
      hide_window_decorations = "yes";
      background_opacity = 0.85;
      hide_mouse_cursor_when_typing = "yes";
      include = "~/.config/kitty/mocha.conf";
      cursor_blink_interval = 0;
      cursor_shape = "beam";
    };
  };

  home.file.".config/kitty" = {
    recursive = true;
    source = ./config;
  };

  # I disabled image support for neovim because it just doesn't quite work with the text yet.
  # I'm hoping to be able to enable this in the future.
  ## Enable neovim image support
  #programs.neovim = {
  #  extraLuaPackages = ps: [ ps.magick ];
  #  extraPackages = [ pkgs.imagemagick ];
  #  plugins = with pkgs.vimPlugins; [{
  #    plugin = image-nvim;
  #    type = "lua";
  #    config = builtins.readFile(./image-nvim.lua);
  #  }];
  #};

  # Enable tmux image support
  programs.tmux = {
    extraConfig = ''
      set -gq allow-passthrough on
      set -g visual-activity off
    '';
  };
}
