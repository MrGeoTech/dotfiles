{inputs, pkgs, ...} : {
  imports = [
    inputs.winix.nixosModules.winix
  ];

  # dockur/windows (the VM winix drives) needs /dev/kvm + NET_ADMIN/NET_RAW +
  # a tun device -- simplest with a normal rootful dockerd, not rootless.
  virtualisation.docker.enable = true;

  winix = {
    enable = true;
    systemUser = "mrgeotech";

    # Nothing here uses an automated `installer` (see the cst-studio entry
    # below), so this directory doesn't need to exist yet.
    installers = "/home/mrgeotech/vms/winix-installers";

    rdp = {
      user = "mrgeotech";
      # Plaintext by design in winix v1 -- lands world-readable in
      # /nix/store. Fine for a VM only reachable on 127.0.0.1. Change it.
      password = "changeme123";
    };

    vm = {
      ramSize = "8G";
      cpuCores = 4;
      diskSize = "80G";
    };

    apps = [
      {
        name = "cst-studio";
        fullName = "CST Studio Suite";
        # Guessed path -- CST installs itself under a version-named folder,
        # confirm the real one after the manual install and fix this up.
        winExecutable = "C:\\Program Files\\CST Studio Suite 2026\\CST DESIGN ENVIRONMENT.exe";
        # No `installer` set on purpose: CST's installer isn't known to
        # silent-install cleanly, so the first run is manual. Run
        # `winapps windows` once for a full desktop, install CST from the
        # shared folder (your $HOME is mounted at /shared in the VM), then
        # `cst-studio` launches it as a RemoteApp from then on.
      }
    ];
  };
}
