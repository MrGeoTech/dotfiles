{
  pkgs,
  outputs,
  inputs,
  ...
}: {
  imports = [
    # Hardware config
    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-gpu-amd
    ./hardware-configuration.nix
    ./headless.nix

    # Common config
    ../common/core

    # Optional configs
    ../common/optional
    ../common/optional/virtualisation.nix
    (import ../common/optional/wireguard.nix {
      ip = "5";
    })
    ../common/optional/ups.nix
    # VictoriaMetrics on the weaponized_autism VM, reached over wg0.
    (import ../common/optional/metrics.nix {
      url = "http://10.0.1.50:8428";
      user = "wa";
    })

    # User config
    ../common/users/mrgeotech
  ];
  # Dynamic instead of pinned: amd-pstate-epp's powersave governor still
  # boosts on demand, steered by EPP. gamemode flips the governor to
  # performance while a game runs and back afterwards.
  powerManagement.cpuFreqGovernor = "powersave";
  powerManagement.enable = true;
  systemd.tmpfiles.rules = [
    "w /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference - - - - balance_performance"
  ];

  boot.kernel.sysctl = {
    # Don't stall split-lock-heavy games (some Proton titles) with the
    # kernel's deliberate split-lock slowdown.
    "kernel.split_lock_mitigate" = 0;
    # zram swap is cheap to hit, so let the kernel prefer it over dropping
    # page cache (the value the zram docs / Fedora use).
    "vm.swappiness" = 180;
  };

  # Bootloader.
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

    # Lets nix build aarch64-linux derivations here via qemu emulation
    # instead of erroring with "platform mismatch" -- needed to build the
    # pi5 sd-image for the bison_pullers/panel flake from this x86_64 box.
    binfmt.emulatedSystems = [ "aarch64-linux" ];

    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      timeout = 1;
    };
  };

  # amd gpu support for kernel
  boot.initrd.kernelModules = ["amdgpu"];

  # Samsung Odyssey G9 (LC49G95T) on DP-1: override its EDID to get 240Hz.
  # The monitor rewrites its own EDID based on the OSD "Refresh Rate"
  # setting, and the 240Hz version it sends makes amdgpu flicker/drop the
  # signal (drm/amd#1442). This is the hand-fixed EDID from
  # github.com/vpraion/odysseyg9-linux-240hz-vrr-hdr-noflicker: a
  # 5120x1440@239.58 DSC timing, 60-240Hz VRR range, and HDR10 metadata.
  # The OSD Refresh Rate must be set to 240Hz for this to display anything.
  hardware.display = {
    edid.packages = [
      (pkgs.runCommand "edid-lc49g95" {} ''
        install -Dm444 ${./LC49G95.bin} $out/lib/firmware/edid/LC49G95.bin
      '')
    ];
    outputs."DP-1".edid = "LC49G95.bin";
  };
  # amdgpu probes the monitor from the initrd, before the real
  # /lib/firmware exists, so the EDID has to be in there too.
  boot.initrd.extraFirmwarePaths = ["edid/LC49G95.bin"];


  # Transparent zstd on root. Safe to add to an existing fs: only new
  # writes get compressed. Recompress old data with
  #   sudo btrfs filesystem defragment -r -czstd /
  fileSystems."/".options = [ "compress=zstd" "noatime" ];

  networking = {
    networkmanager = {
      wifi.powersave = false;
    };
    hostName = "mrgeotech-pc";
  };

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        #amdvlk 
        #driversi686Linux.amdvlk
        rocmPackages.clr
        rocmPackages.clr.icd
      ];
    };
    enableAllFirmware = true;
  };

  # Load amd driver for Xorg and Wayland
  services.xserver.videoDrivers = ["amdgpu"];
  console.useXkbConfig = true;

  # Configure keymap in X11
  services.xserver = {
    enable = false;
    xkb.options = "ctrl:nocaps";
    xkb.layout = "us";
    xkb.variant = "";
  };

  system.stateVersion = "26.05";
}
