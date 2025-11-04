{inputs, pkgs, ...} : {
  virtualisation = {
    docker = {
      enable = true;
      enableOnBoot = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };
    libvirtd = {
      enable = true;
      package = with pkgs; libvirt;
      qemu = {
        package = with pkgs; qemu;
        swtpm = {
          enable = false;
          package = with pkgs; swtpm;
        };
      };
    };
    spiceUSBRedirection.enable = true;
  };
  services.spice-vdagentd.enable = true;
  programs.virt-manager.enable = true;
  
  environment.systemPackages = [
  #  inputs.winapps.packages.${pkgs.system}.winapps
  #  inputs.winapps.packages.${pkgs.system}.winapps-launcher
  #  pkgs.freerdp
    pkgs.bottles
  ];
}
