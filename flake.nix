{
    description = "NixOS hyprland setup";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

        hardware.url = "github:nixos/nixos-hardware";
        nix-colors.url = "github:misterio77/nix-colors";

        # home-manager
        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        # secrets
        sops-nix = {
            url = "github:Mic92/sops-nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        # hyprland
        hyprland = {
            url = "github:hyprwm/hyprland";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        hyprland-plugins = {
            url = "github:hyprwm/hyprland-plugins";
            inputs.hyprland.follows = "hyprland";
        };

        # catppuccin
        catppuccin.url = "github:catppuccin/nix";

        # ghostty
        ghostty = {
            url = "github:ghostty-org/ghostty";
        };
    };

    outputs = {
        self,
        nixpkgs,
        home-manager,
        catppuccin,
        ghostty,
        ...
    } @ inputs: 
    let
        inherit (self) outputs;
        lib = nixpkgs.lib // home-manager.lib;

        systems = ["x86_64-linux"];
        forEachSystem = f: lib.genAttrs systems (system: f pkgsFor.${system});

        pkgsFor = lib.genAttrs systems (system:
            import nixpkgs {
                inherit system;
                config.allowUnfree = true;
            }
        );
    in {
        inherit lib;

        #packages = forEachSystem (pkgs: import ./pkgs { inherit pkgs; });

        formatter = forEachSystem (pkgs: pkgs.alejandra);

        devShells = forEachSystem (pkgs: import ./shell.nix { inherit pkgs; });

        nixosConfigurations = {
            # Desktop
            mrgeotech-pc = lib.nixosSystem {
                specialArgs = {inherit inputs outputs;};
                modules = [
                    ./hosts/mrgeotech-pc
                    home-manager.nixosModules.home-manager
                    catppuccin.nixosModules.catppuccin
                    ({config, ...}: {
                        home-manager.backupFileExtension = "bak";
                        home-manager.extraSpecialArgs = {
                            inherit inputs outputs;
                            inherit (config.networking) hostName;
                        };
                    })
                ];
            };

            # Laptop
            mrgeotech-laptop = lib.nixosSystem {
                specialArgs = {inherit inputs outputs;};
                modules = [
                    ./hosts/mrgeotech-laptop
                    home-manager.nixosModules.home-manager
                    catppuccin.nixosModules.catppuccin
                    ({config, ...}: {
                        home-manager.backupFileExtension = "bak";
                        home-manager.extraSpecialArgs = {
                            inherit inputs outputs;
                            inherit (config.networking) hostName;
                        };
                    })
                ];
            };

            # New Laptop (Zenbook)
            mrgeotech-zenbook = lib.nixosSystem {
                specialArgs = {inherit inputs outputs;};
                modules = [
                    ./hosts/mrgeotech-zenbook
                    home-manager.nixosModules.home-manager
                    catppuccin.nixosModules.catppuccin
                    ({config, ...}: {
                        home-manager.backupFileExtension = "bak";
                        home-manager.extraSpecialArgs = {
                            inherit inputs outputs;
                            inherit (config.networking) hostName;
                        };
                    })
                ];
            };

            # Website host
            www = lib.nixosSystem {
                specialArgs = {inherit inputs outputs;};
                modules = [
                    ./hosts/www
                    home-manager.nixosModules.home-manager
                    catppuccin.nixosModules.catppuccin # Why not?
                    ({config, ...}: {
                        home-manager.backupFileExtension = "bak";
                        home-manager.extraSpecialArgs = {
                            inherit inputs outputs;
                            inherit (config.networking) hostName;
                        };
                    })
                ];
            };
        };
    };
}
