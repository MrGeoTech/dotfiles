# https://github.com/sxyazi/yazi
{
    # NOTE: Default keybinding are here: https://github.com/sxyazi/yazi/blob/main/yazi-config/preset/keymap.toml
    programs.yazi = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
        settings = {
            theme = ./themes/theme.toml;
            mgr = {
                show_hidden = true;
                sort_by = "alphabetical";
                sort_sensitive = false;
                sort_dir_first = true;
                sort_reverse = false;
            };
        };
    };

    # Copy tmTheme
    home.file.".config/yazi/Catppuccin-mocha.tmTheme" = {
        source = ./themes/Catppuccin-mocha.tmTheme;
    };

    # aliases
    home.shellAliases = {
        y = "yazi";
    };
}
