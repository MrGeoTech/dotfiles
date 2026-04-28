{
  description = "NixOS hyprland setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    hardware.url = "github:nixos/nixos-hardware";
    nix-colors.url = "github:misterio77/nix-colors";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    catppuccin.url = "github:catppuccin/nix";

    ghostty = {
      url = "github:ghostty-org/ghostty";
    };

    winapps = {
      url = "github:winapps-org/winapps";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    labrador = {
      url = "github:espotek-org/Labrador?rev=3119205cdde183039062621c1204584f1ec1c5ac";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    catppuccin,
    ghostty,
    labrador,
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

      #labrador-fixed = lib.genAttrs systems (system:
      #  labrador.packages.${system}.default.overrideAttrs (old: {
      #    src = pkgsFor.${system}.fetchFromGitHub {
      #      owner = "espotek-org";
      #      repo = "Labrador";
      #      rev = "3119205cdde183039062621c1204584f1ec1c5ac";
      #      hash = "sha256-ERSHtiuq1l3sEk5OdVxoG1ri/4HZ0Fi4KFkWW09ZKyI=";
      #      fetchSubmodules = true;
      #    };
      #    #postPatch = ''
      #    #  echo 'QMAKE_CFLAGS += -std=c11' >> Desktop_Interface/Labrador.pro
      #    #'';
      #  })
      #);
    in {
      inherit lib;

      myPkgs = forEachSystem (pkgs: import ./pkgs {inherit pkgs;});

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

        # steam-machine
        steam-machine = lib.nixosSystem {
          specialArgs = {inherit inputs outputs;};
          modules = [
            ./hosts/steam-machine
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
      };
    };
}
