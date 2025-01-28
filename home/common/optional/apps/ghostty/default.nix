{ inputs, ... }:
{
    home.packages = [
        inputs.ghostty.packages.x86_64-linux.default
    ];

    home.file.".config/ghostty/config" = {
        source = ./config;
    };
}
