# https://github.com/sxyazi/yazi
# NOTE: Default keybindings: https://github.com/sxyazi/yazi/blob/main/yazi-config/preset/keymap.toml
#
# Ghostty speaks the Kitty graphics protocol, so image previews work with no
# ueberzug shim -- but yazi shells out to external tools for the actual
# decoding. Without them you get "Image preview is not available" and no
# explanation, which is why the preview deps are listed explicitly below.
{pkgs, ...}: {
  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    shellWrapperName = "y";

    plugins = {
      inherit
        (pkgs.yaziPlugins)
        chmod            # bulk chmod on selected files
        diff             # diff selection against the hovered file
        full-border      # rounded border matching the rest of the theme
        mount            # mount/unmount removable media without leaving yazi
        relative-motions # THE one: type 5j to jump 5 down, like vim
        smart-enter      # `l` opens files and enters directories
        toggle-pane      # maximize preview / hide parent
        ;
      # git status column disabled for now: nixpkgs' yaziPlugins.git
      # (currently pinned to yazi-rs/plugins@b9598e6, 2026-08-03) predates
      # upstream's `fetch_compact` shim for yazi core's coroutine-based
      # fetcher protocol, so it errors with "error converting Lua boolean
      # to function" on every fetch. Re-add `git` here (plus its fetcher
      # rules and `require("git"):setup()` in initLua below) once nixpkgs
      # updates the pin past that fix.
    };

    settings = {
      theme = ./themes/theme.toml;

      mgr = {
        show_hidden = true;
        sort_by = "alphabetical";
        sort_sensitive = false;
        sort_dir_first = true;
        sort_reverse = false;
        linemode = "size";
        ratio = [ 1 3 4 ];  # narrower parent, wider preview
      };

      preview = {
        max_width = 1000;
        max_height = 1000;
        image_filter = "lanczos3";
        ueberzug_scale = 1;
      };

      # Route Enter/`o` to the same lean tools you use elsewhere, instead of
      # whatever xdg-open decides. Matches the mimeApps cleanup.
      # `%s`/`%s1` etc. are yazi's own opener placeholders -- it splices
      # shell-escaped real paths directly into the run string before
      # handing the whole thing to the shell, it does NOT pass files as
      # extra argv, so shell-style "$@"/"$1" here always expand empty.
      opener = {
        edit = [{ run = "nvim %s"; block = true; desc = "nvim"; }];
        play = [{ run = "mpv --force-window %s"; orphan = true; desc = "mpv"; }];
        pdf = [{ run = "zathura %s"; orphan = true; desc = "zathura"; }];
        image = [{ run = "imv %s"; orphan = true; desc = "imv"; }];
        extract = [{ run = "ouch decompress %s"; desc = "extract here"; }];
        reveal = [{ run = ''exiftool %s1; echo "Press enter to exit"; read _''; block = true; desc = "exiftool"; }];
      };

      open.prepend_rules = [
        { mime = "application/pdf"; use = "pdf"; }
        { mime = "image/*"; use = [ "image" "reveal" ]; }
        { mime = "{audio,video}/*"; use = [ "play" "reveal" ]; }
        { mime = "application/{zip,gzip,x-tar,x-bzip*,x-7z-compressed,x-rar,xz}"; use = [ "extract" "reveal" ]; }
        { url = "*/"; use = [ "edit" "open" "reveal" ]; }
      ];
    };

    keymap = {
      mgr.prepend_keymap = [
        # --- vim-style navigation additions -----------------------------
        { on = "l"; run = "plugin smart-enter"; desc = "Enter dir or open file"; }
        { on = [ "g" "r" ]; run = ''shell -- ya emit cd "$(git rev-parse --show-toplevel)"''; desc = "Go to repo root"; }
        { on = [ "g" "n" ]; run = "cd ~/nixos-config"; desc = "Go to nix config"; }
        { on = "T"; run = "plugin toggle-pane max-preview"; desc = "Maximize preview"; }
        { on = "<C-u>"; run = "arrow -50%"; desc = "Half page up"; }
        { on = "<C-d>"; run = "arrow 50%"; desc = "Half page down"; }

        # --- actions ----------------------------------------------------
        { on = [ "c" "m" ]; run = "plugin chmod"; desc = "chmod selection"; }
        { on = "M"; run = "plugin mount"; desc = "Mount manager"; }
        { on = "<C-d>"; run = "plugin diff"; desc = "Diff against hovered"; }

        # Yank the absolute path to the Wayland clipboard, not just yazi's.
        { on = [ "y" "p" ]; run = ''shell -- printf "%s" "$@" | wl-copy''; desc = "Copy path to clipboard"; }

        # Open a shell in the current directory; exit returns to yazi.
        { on = "!"; run = ''shell "$SHELL" --block''; desc = "Shell here"; }

        # Bulk rename the selection in nvim.
        { on = [ "c" "r" ]; run = "rename --cursor=before_ext"; desc = "Rename"; }
      ];
    };

    initLua = ''
      require("full-border"):setup({ type = ui.Border.ROUNDED })
      require("relative-motions"):setup({
        show_numbers = "relative_absolute",
        show_motion = true,
        enter_mode = "first",
      })
    '';
  };

  # Copy tmTheme
  home.file.".config/yazi/Catppuccin-mocha.tmTheme" = {
    source = ./themes/Catppuccin-mocha.tmTheme;
  };

  # Preview and opener dependencies. Without these, previews silently degrade.
  home.packages = with pkgs; [
    ffmpeg         # video thumbnails + duration metadata
    p7zip          # archive contents preview
    poppler-utils  # PDF preview (pdftoppm)
    imagemagick    # HEIC/SVG/RAW conversion for preview
    exiftool       # the `reveal` opener
    ouch           # single command for every archive format
    chafa          # fallback preview where kitty protocol isn't available
  ];
}
