{
  description = "dotfiles";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixpkgs-unstable;
    # nixpkgs.url = github:nixos/nixpkgs/nixpkgs-21.11-darwin;

    darwin = {
      url = github:lnl7/nix-darwin/master;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = github:nix-community/home-manager/release-21.11;
    };

    neovim = {
      url = github:nix-community/neovim-nightly-overlay;
    };

    spacebar = {
      url = github:cmacrae/spacebar/v1.3.0;
    };

    flake-utils = { 
      url = github:numtide/flake-utils;
    };

    nur = {
      url = github:nix-community/NUR;
    };
  };

  outputs = inputs @ { self, nixpkgs, darwin, home-manager, neovim, flake-utils, nur, spacebar, ... }:
    let
      nixpkgsConfig = with inputs; {
        config = {
          allowUnfree = true;
        };
        # overlays = self.overlays;
        overlays = [ nur.overlay ];
      };

      homeManagerConfig =
        { user
        , userConfig ? ./home + "/user-${user}.nix"
        , ...
        }: {
          imports = [
            userConfig
            ./home
          ];
        };

      mkDarwinModules =
        args @
        { user
        , host
        , hostConfig ? ./config + "/host-${host}.nix"
        , ...
        }: [
          home-manager.darwinModules.home-manager
          {
            nixpkgs.overlays = [ neovim.overlay spacebar.overlay ];
            nixpkgs.config.allowUnfree = true;
          }
          ./config/darwin.nix
          {
            nix.nixPath = {
              inherit nixpkgs darwin;
            };
          }
          # hostConfig
          {
            users.users.${user}.home = "/Users/${user}";
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${user} = homeManagerConfig args;
          }
        ];
    in
    {
      darwinConfigurations = {
        "harrys-mbp" = darwin.lib.darwinSystem {
          system = "x86_64-darwin";
          inputs = { inherit darwin nixpkgs; };
          modules = mkDarwinModules {
            user = "harry";
            host = "harrys-mbp";
          };
        };
      };

      darwinModules = { };

      homeManagerModules = { };

      overlays =
        let path = ./overlays; in
        with builtins;
        map (n: import (path + ("/" + n))) (filter
          (n:
            match ".*\\.nix" n != null
            || pathExists (path + ("/" + n + "/default.nix")))
          (attrNames (readDir path)));
    };
}
