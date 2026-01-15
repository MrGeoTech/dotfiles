{inputs, pkgs, ...} : {
  home.packages = [
    inputs.labrador.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
