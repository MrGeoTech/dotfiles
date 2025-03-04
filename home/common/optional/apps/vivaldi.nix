{ pkgs, ... }:
{
    # https://forum.vivaldi.net/topic/95078/proton-mail-integration/10
    home.packages = with pkgs; [
        vivaldi
        # TODO: Integrate proton bridge into my servers to make
        # vivaldi/other mail clients easier
        # protonmail-bridge-gui
    ];
}
