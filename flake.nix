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
      url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim.url = github:nix-community/neovim-nightly-overlay;
    flake-utils.url = github:numtide/flake-utils;
    nur.url = github:nix-community/NUR;
    kitty.url = github:kovidgoyal/kitty;
    kitty.flake = false;
  };

  outputs = { self, nixpkgs, darwin, home-manager, neovim, flake-utils, nur, kitty, ... } @ inputs:
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

      union = z: s: z ++ builtins.filter (e: !builtins.elem e z) s;

      kittyOverlay = self: super: {
        kitty = super.kitty.overrideAttrs ( old:
        let
          kittyShell = super.callPackage "${kitty}/shell.nix" {};
        in {
          name = "kitty-nightly";
          version = "${old.version}-nightly";
          src = kitty;
          buildInputs = union old.buildInputs kittyShell.buildInputs;
          nativeBuildInputs = union old.nativeBuildInputs kittyShell.nativeBuildInputs;
          propagatedBuildInputs = union old.propagatedBuildInputs kittyShell.propagatedBuildInputs;
        });
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
            nix.nixPath = {
              inherit nixpkgs darwin;
              darwin-config = ./config/darwin.nix;
            };
            nixpkgs.overlays = [ neovim.overlay kittyOverlay ];
            nixpkgs.config.allowUnfree = true;
          }
          ./config/darwin.nix
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
