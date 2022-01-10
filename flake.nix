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

  outputs = { nixpkgs, darwin, home-manager, neovim, kitty, ... } @ inputs:
    let
      union = z: s: z ++ builtins.filter (e: !builtins.elem e z) s;

      kittyOverlay = self: super: {
        kitty = super.kitty.overrideAttrs ( old:
        let
          kittyShell = super.callPackage "${kitty}/shell.nix" {}; # is this safe? who knows
        in {
          name = "${old.name}-nightly"; # this should always be kitty-nightly but whatever
          version = "${old.version}-nightly"; # eventually I'd like to generate this from kitty/constants.py:25
          src = kitty;
          # this could pottentially lead to a few unnecessary inputs but considering
          # my alternative way of installing kitty is just using nix-shell I'd be
          # building them anyway
          buildInputs = union old.buildInputs kittyShell.buildInputs;
          nativeBuildInputs = union old.nativeBuildInputs kittyShell.nativeBuildInputs;
          propagatedBuildInputs = union old.propagatedBuildInputs kittyShell.propagatedBuildInputs;
          outputs = union old.outputs ["shell_integration"]; # nixpkgs#153999
          # https://github.com/NixOS/nixpkgs/pull/153999
        });
      };

      nixpkgsConfig = {
        config.allowUnfree = true;
        overlays = [ neovim.overlay kittyOverlay ];
      };

      homeManagerConfig =
        { user, userConfig ? ./home+"/user-${user}.nix", ... }: {
          imports = [ userConfig ./home ];
        };

      mkDarwinModules =
        { user, host, hostConfig ? ./config+"/host-${host}.nix", ... } @ args: [
          home-manager.darwinModules.home-manager
          {
            nix.nixPath = {
              inherit nixpkgs darwin;
              darwin-config = ./config/darwin.nix;
            };
            nixpkgs = nixpkgsConfig;
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

      # this is only here because I stole this file from someone else
      # maybe in the future I'll use it
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
