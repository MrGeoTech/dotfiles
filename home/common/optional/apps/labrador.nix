#{pkgs, outputs, ...} : {
{pkgs, inputs, ...} : {
  home.packages = [
    inputs.labrador.packages.${pkgs.stdenv.hostPlatform.system}.default
    #outputs.labrador-fixed.${pkgs.stdenv.hostPlatform.system}
  ];
}
