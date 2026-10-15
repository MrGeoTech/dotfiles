{inputs, config, pkgs, lib, ...} : let
  # Same age identity sops-nix uses (see hosts/common/users/mrgeotech).
  # Every `encrypted = true` installer is encrypted to its public half,
  # the recipient in .sops.yaml:
  #   age -r age10tn8mslgvx3cg58guvqz88eee7qjglkycq79t3jxee0gdc5mjefq2eqrmd \
  #     -o foo.exe.age foo.exe
  ageKeyFile = "/home/mrgeotech/.config/sops/age/keys.txt";

  # Where decrypted installers land. Root-only, outside /nix/store, so the
  # plaintext never becomes world-readable. winix copies from here into the
  # VM's OEM payload (~/.config/winapps/oem) on every activation.
  installerDir = "/var/lib/winix-installers";

  rdpPasswordToken = "@WINIX_RDP_PASSWORD@";

  releaseAsset = file: "https://github.com/MrGeoTech/dotfiles/releases/download/winix-installers/${file}";

  # Like winix.apps, plus an optional `installer` = { url, hash, encrypted,
  # args }. `url` can be anything fetchurl understands: an age-encrypted
  # GitHub release asset (encrypted = true), or a vendor's own direct
  # download link (encrypted = false). Get `hash` with
  #   nix hash file --sri <file>     (or nix-prefetch-url <url>)
  # Installers run once, silently, the first time the Windows VM is
  # created -- they do nothing for a VM that already exists.
  apps = [
    {
      name = "cst-studio";
      fullName = "CST Studio Suite";
      winExecutable = "C:\\Program Files\\CST Studio Suite 2026\\CST DESIGN ENVIRONMENT.exe";
      installer = {
        # CST_Studio_Suite_2026_Learning_Edition_Setup.exe
        url = releaseAsset "cst-studio.exe.age";
        hash = "sha256-TislaGofhXMEtT8LOM7yvqlAH/R0fxoYSRrinmBJI1Q=";
        encrypted = true;
        # InstallShield wrapper around an MSI: /s silences the bootstrapper,
        # /v passes the rest straight to msiexec.
        args = [ "/s" "/v\"/qn REBOOT=ReallySuppress\"" ];
      };
    }
    {
      name = "fusion";
      fullName = "Autodesk Fusion";
      # 6a0c96... is Fusion's fixed launcher folder, not a per-version hash
      # (upstream WinApps' fusion-360 entry uses the same one).
      winExecutable = "C:\\Users\\mrgeotech\\AppData\\Local\\Autodesk\\webdeploy\\production\\6a0c9611291d45bb9226980209917c3d\\FusionLauncher.exe";
      installer = {
        # "Fusion Client Downloader.exe" from
        # https://dl.appstreaming.autodesk.com/production/installers/Fusion%20Client%20Downloader.exe
        # Only a stub -- it pulls the real install from Autodesk, so the
        # VM needs network on first boot.
        url = releaseAsset "fusion.exe.age";
        hash = "sha256-AHXLtWtjQKSA0bJCDTWptfRF2gVBEDpeuWtXCHtyN/E=";
        encrypted = true;
        args = [ "--quiet" ];
      };
    }
  ];

  withInstaller = builtins.filter (app: app ? installer) apps;

  fetchInstaller = app: pkgs.fetchurl {
    name = "winix-${app.name}-installer${lib.optionalString app.installer.encrypted ".age"}";
    inherit (app.installer) url hash;
  };

  # Decrypting 1.5G on every rebuild is wasteful, so each installer keeps a
  # stamp of the store path it came from and is only redone when that
  # changes. On failure (e.g. no age key yet on a fresh machine) an empty
  # placeholder keeps winix's own `set -e` copy step from aborting the rest
  # of activation; no stamp is written, so the next activation retries.
  prepareInstaller = app: let
    src = fetchInstaller app;
    dir = "${installerDir}/${app.name}";
  in ''
    (
      set -e
      dst="${dir}/installer.exe"
      install -d -m700 "${dir}"
      if [ "$(cat "$dst.src" 2>/dev/null)" != "${src}" ]; then
        rm -f "$dst" "$dst.src"
        ${if app.installer.encrypted then ''
          if ${pkgs.age}/bin/age -d -i "${ageKeyFile}" -o "$dst.tmp" "${src}"; then
            mv "$dst.tmp" "$dst"
          else
            rm -f "$dst.tmp"
            echo "winix: couldn't decrypt the ${app.name} installer with ${ageKeyFile}" >&2
            touch "$dst"
            exit 1
          fi
        '' else ''
          ln -s "${src}" "$dst"
        ''}
        echo "${src}" > "$dst.src"
      fi
    ) || _localstatus=$?
  '';
in {
  imports = [
    inputs.winix.nixosModules.winix
  ];

  # dockur/windows (the VM winix drives) needs /dev/kvm + NET_ADMIN/NET_RAW +
  # a tun device -- simplest with a normal rootful dockerd, not rootless.
  virtualisation.docker.enable = true;

  # Publish RDP (and the noVNC viewer on 8006) on the wg address too, so
  # other wireguard machines can use this machine's VM. Not 0.0.0.0:
  # docker-published ports skip the NixOS firewall, so that would put
  # Windows RDP on the LAN. ip_nonlocal_bind lets docker bind the wg
  # address even if wg0 isn't up yet (e.g. no network at boot) instead of
  # refusing to start the container.
  boot.kernel.sysctl."net.ipv4.ip_nonlocal_bind" = 1;

  system.activationScripts.winixInstallers = {
    deps = [ "users" ];
    text = lib.concatMapStrings prepareInstaller withInstaller;
  };
  system.activationScripts.winixConfig.deps = [ "winixInstallers" ];

  # The real RDP/Windows password lives in sops. winix only ever sees
  # `rdpPasswordToken` (so that's all that reaches /nix/store and GitHub),
  # and this swaps it for the decrypted secret in the two files winix just
  # wrote, both of which stay readable only by mrgeotech. Read it with
  #   sudo cat /run/secrets/winix-rdp-password
  # Keep it alphanumeric: it's pasted unescaped into a double-quoted shell
  # var (winapps.conf) and a double-quoted YAML string (compose.yaml).
  sops.secrets."winix-rdp-password".sopsFile = ./secrets/winix.yaml;

  # winix hardcodes 127.0.0.1 in compose.yaml; add a wg-address copy of
  # each published port after it writes the file.
  system.activationScripts.winixWireguard = {
    deps = [ "winixConfig" "winixRdpPassword" ];
    text = ''
      wgIp=${lib.escapeShellArg (lib.head (lib.splitString "/" (lib.head config.networking.wg-quick.interfaces.wg0.address)))}
      ${pkgs.gnused}/bin/sed -i "s|^\( *\)- \"127.0.0.1:\([0-9]*:[0-9/a-z]*\)\"$|&\n\1- \"$wgIp:\2\"|" /home/mrgeotech/.config/winapps/compose.yaml
    '';
  };

  system.activationScripts.winixRdpPassword = {
    deps = [ "winixConfig" "setupSecrets" ];
    text = ''
      (
        set -e
        secret=/run/secrets/winix-rdp-password
        dir=/home/mrgeotech/.config/winapps
        if [ -r "$secret" ]; then
          pw="$(cat "$secret")"
          for f in "$dir/winapps.conf" "$dir/compose.yaml"; do
            ${pkgs.gnused}/bin/sed -i "s|${rdpPasswordToken}|$pw|g" "$f"
            chmod 600 "$f"
          done
        else
          echo "winix: $secret missing, RDP password left as a placeholder" >&2
          exit 1
        fi
      ) || _localstatus=$?
    '';
  };

  winix = {
    enable = true;
    systemUser = "mrgeotech";

    installers = installerDir;

    rdp = {
      user = "mrgeotech";
      # Not the real password -- see winixRdpPassword above.
      password = rdpPasswordToken;
    };

    vm = {
      ramSize = "8G";
      cpuCores = 4;
      diskSize = "80G";
    };

    # Fully stop (not just pause) the Windows container after 5 minutes with
    # no WinApps RDP session open, to give the RAM/CPU back to the host.
    # Trade-off: next launch takes a full Windows boot instead of an
    # instant unpause.
    autopause = {
      enable = true;
      action = "stop";
      time = 300;
    };

    apps = map (app:
      builtins.removeAttrs app [ "installer" ]
      // lib.optionalAttrs (app ? installer) {
        installer = "installer.exe";
        installArgs = app.installer.args or [ ];
      }
    ) apps;
  };
}
