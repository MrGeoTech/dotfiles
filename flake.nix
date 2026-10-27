{
  description = "NixOS hyprland setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    hardware.url = "github:nixos/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin.url = "github:catppuccin/nix";

    # Prebuilt nixpkgs file->package index, kept up to date automatically
    # via `nix flake update`. Backs `launch`/`comma` so unknown
    # commands can be searched and run sandboxed without ever having to
    # build a local index.
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # App launcher (rofi + terminal) over installed apps and all of nixpkgs,
    # see home/common/core/cli/launch.nix. Local checkout for now; switch to
    # github:<you>/nix-launch once it's pushed.
    nix-launch = {
      url = "path:/home/mrgeotech/Projects/nix-launch";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    winix = {
      url = "github:Dotfile-Suite/wiNix/winix-module";
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

            catppuccin.nixosModules.catppuccin
            home-manager.nixosModules.home-manager

            ({config, ...}: {
              home-manager.backupFileExtension = "bak";
              home-manager.extraSpecialArgs = {
                inherit inputs outputs;
                inherit (config.networking) hostName;
              };
            })
          ];
        };

        # Laptop (Zenbook)
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
