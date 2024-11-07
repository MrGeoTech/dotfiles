{ pkgs, ... }: {
  services.rpcbind.enable = true;
  systemd.mount = [{
    type = "nfs";
    mountConfig = {
      Options = "noatime";
    };
    what = "mrgeotech.net/Shared";
    where = "/shared";
  }];

  systemd.automounts = [{
    wantedBy = [ "multi-user.target" ];
    automatedConfig = {
      TimeoutIdleSec = "600";
    };
    where = "/shared";
  }];
}
