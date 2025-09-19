{ config, pkgs, ... }:

let
  steamosTheme = pkgs.stdenv.mkDerivation {
    pname = "plymouth-theme-steamos";
    version = "0.17+bsos2";
    src = pkgs.fetchurl {
      url = "https://repo.steampowered.com/steamos/pool/main/p/plymouth-themes-steamos/plymouth-themes-steamos_0.17.tar.xz";
      sha256 = "sha256-RLMJYlVSPzMsSe5LtWdWBbsuk1ZejQ73JUp6LPYNjlM=";
    };

    installPhase = ''
      mkdir -p $out/share/plymouth/themes
      cp -r steamos-* $out/share/plymouth/themes/
    '';
  };
in
{
  boot.plymouth = {
    enable = true;
    theme = "steamos";
    themePackages = [ steamosTheme ];
  };
}
