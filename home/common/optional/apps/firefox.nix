{ config, pkgs, ... }:

  let
    lock-false = {
      Value = false;
      Status = "locked";
    };
    lock-true = {
      Value = true;
      Status = "locked";
    };
  in
{
  programs = {
    firefox = {
      enable = true;
      languagePacks = [ "en-US" ];

      /* ---- POLICIES ---- */
      # Check about:policies#documentation for options.
      policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
        OverrideFirstRunPage = "";
        OverridePostUpdatePage = "";
        DontCheckDefaultBrowser = true;
        DisplayBookmarksToolbar = "always"; # alternatives: "always" or "newtab"
        DisplayMenuBar = "default-off"; # alternatives: "always", "never" or "default-on"
        SearchBar = "unified"; # alternative: "separate"

        /* ---- EXTENSIONS ---- */
        # Check about:support for extension/add-on ID strings.
        # Valid strings for installation_mode are "allowed", "blocked",
        # "force_installed" and "normal_installed".
        ExtensionSettings = {
          "*".installation_mode = "blocked"; # blocks all addons except the ones specified below
	  # Catppuccin Theme
	  "{73eb68a8-ea35-4527-9666-304ce1ce1054}" = {
	    install_url = "https://addons.mozilla.org/firefox/downloads/file/3975428/catpuccin-1.1.xpi";
	    installation_mode = "force_installed";
	  };
        };
  
        /* ---- PREFERENCES ---- */
        # Check about:config for options.
        Preferences = { 
          "browser.contentblocking.category" = { Value = "strict"; Status = "locked"; };
          "extensions.pocket.enabled" = lock-false;
          "extensions.screenshots.disabled" = lock-true;
          "browser.topsites.contile.enabled" = lock-false;
          "browser.search.suggest.enabled.private" = lock-false;
          "browser.urlbar.suggest.searches" = lock-false;
          "browser.urlbar.showSearchSuggestionsFirst" = lock-false;
          "browser.newtabpage.activity-stream.feeds.section.topstories" = lock-false;
          "browser.newtabpage.activity-stream.feeds.snippets" = lock-false;
          "browser.newtabpage.activity-stream.section.highlights.includePocket" = lock-false;
          "browser.newtabpage.activity-stream.section.highlights.includeBookmarks" = lock-false;
          "browser.newtabpage.activity-stream.section.highlights.includeDownloads" = lock-false;
          "browser.newtabpage.activity-stream.section.highlights.includeVisited" = lock-false;
          "browser.newtabpage.activity-stream.showSponsored" = lock-false;
          "browser.newtabpage.activity-stream.system.showSponsored" = lock-false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = lock-false;
        };
      };
    };
  };
}
