{
  # Docker
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };
  # Virt-Manager
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
  programs.virt-manager.enable = true;
}
