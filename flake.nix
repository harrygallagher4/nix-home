{
  description = "dotfiles";

  inputs = {
    # nixpkgs.url = github:nixos/nixpkgs/nixpkgs-unstable;
    nixpkgs.url = github:nixos/nixpkgs/nixpkgs-21.11-darwin;

    darwin = {
      url = github:lnl7/nix-darwin/master;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = github:nix-community/home-manager/release-21.11;
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim = {
      url = github:nix-community/neovim-nightly-overlay;
      # url = github:/neovim/neovim/master?dir=contrib;
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    spacebar = {
      url = github:cmacrae/spacebar/v1.3.0;
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils = { 
      url = github:numtide/flake-utils;
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = github:nix-community/NUR;
      # inputs.nixpkgs.follows = "nixpkgs";
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
            # nix.nixPath = [ { nixpkgs = nixpkgs; } ];
          }
          ./config/darwin.nix
          # hostConfig
          {
            users.users.${user}.home = "/Users/${user}";
            home-manager.useGlobalPkgs = true;
            home-manager.users.${user} = homeManagerConfig args;
            # home-manager.useUserPackages = true;
            # nixpkgs = nixpkgsConfig;
            # nix.nixPath = {
            #   nixpkgs = "$HOME/.config/nixpkgs/nixpkgs.nix";
            # };
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
