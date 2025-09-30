{pkgs, inputs, ...}: {
    home.packages = with pkgs; [
        prismlauncher
        protonup
    ];
}
