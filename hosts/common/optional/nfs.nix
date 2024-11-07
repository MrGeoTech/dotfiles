{ pkgs, ... }: {
  environment.systemPackages = [ pkgs.nfs-utils ];
  boot.initrd = {
    supportedFilesystems = [ "nfs" ];
    kernelModules = [ "nfs" ];
  };

  services.rpcbind.enable = true;
  services.cachefilesd.enable = true;

  systemd.mounts = [{
    type = "nfs";
    mountConfig = {
      Options = "noatime,fsc";
    };
    what = "mrgeotech.net:/mnt/Encypted/Shared";
    where = "/shared";
  }];

  systemd.automounts = [{
    wantedBy = [ "multi-user.target" ];
    automountConfig = {
      TimeoutIdleSec = "600";
    };
    where = "/shared";
  }];
}
