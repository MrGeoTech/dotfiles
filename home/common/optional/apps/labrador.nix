{inputs, pkgs, ...} : {
  home.packages = [
    inputs.labrador.packages.${pkgs.system}.default
  ];
}
