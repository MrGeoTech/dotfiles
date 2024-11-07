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

    # hyprland
    hyprland = {
      url = "github:hyprwm/hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    inherit (self) outputs;
    lib = nixpkgs.lib // home-manager.lib;
    systems = ["x86_64-linux"];
    forEachSystem = f: lib.genAttrs systems (system: f pkgsFor.${system});
    pkgsFor = lib.genAttrs systems (system:
      import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      });
  in {
    inherit lib;

    nixosModules = import ./modules/nixos;
    homeManagerModules = import ./modules/home-manager;

    # Custom modifications/overrides to upstream packages.
    overlays = import ./overlays {inherit inputs outputs;};

    # Custom packages to be shared or upstreamed.
    packages = forEachSystem (pkgs: import ./pkgs {inherit pkgs;});

    formatter = forEachSystem (pkgs: pkgs.alejandra);

    devShells = forEachSystem (pkgs: import ./shell.nix {inherit pkgs;});

    # NOTE: home-manager is also imported as a module within nixosConfigurations
    nixosConfigurations = {
      # Desktop
      mrgeotech-pc = lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          ./hosts/mrgeotech-pc
          home-manager.nixosModules.home-manager
          ({config, ...}: {
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
          ({config, ...}: {
            home-manager.extraSpecialArgs = {
              inherit inputs outputs;
              inherit (config.networking) hostName;
            };
          })
        ];
      };

      # For testing in a vm
      mrgeotech-testing = lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          ./hosts/mrgeotech-testing
          home-manager.nixosModules.home-manager
          ({config, ...}: {
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
