{ pkgs, ... }:
{
    # https://forum.vivaldi.net/topic/95078/proton-mail-integration/10
    home.packages = with pkgs; [
        vivaldi
        protonmail-bridge-gui
    ];
}
