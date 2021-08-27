{ pkgs, lib, ... }:
let
  home_directory = "$HOME";
in
{
  imports = [];

  environment = {
    systemPackages = [
      pkgs.zsh
      pkgs.nixUnstable
      pkgs.neovim-nightly
      pkgs.neovim-remote
      # pkgs.nixFlakes
      pkgs.tree-sitter
      # pkgs.nur.repos.mic92.hello-nur
    ];

    shells = [
      "/usr/local/bin/zsh"
      pkgs.zsh
    ];

    variables = {
      # https://github.com/nix-community/home-manager/issues/423
      TERMINFO_DIRS = "/Applications/kitty.app/Contents/Resources/terminfo";
    };
  };

  nix = {
    # package = pkgs.nixFlakes;
    package = pkgs.nixUnstable;
    # nixPath = [
    #   { nixpkgs = "${home_directory}/.nix-defexpr/channels/nixpkgs"; }
    #   "/nix/var/nix/profiles/per-user/root/channels"
    #   "${home_directory}/.nix-defexpr/channels"
    # ];
    # experimental-features = nix-command flakes ca-references
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';
    maxJobs = 8;
    buildCores = 8;
    trustedUsers = [
      "harry"
      "@staff"
      "@admin"
    ];
  };

  services.nix-daemon.enable = true;
  users.nix.configureBuildUsers = true;
  system.stateVersion = 4;

  programs = {
    zsh = {
      enable = true;
      enableBashCompletion = false;
      enableCompletion = false;
    };
  };

  services.spacebar = {
    enable = true;
    package = pkgs.spacebar;

    config = {
      position                    = "top";
      display                     = "main";
      height                      = 22;
      title                       = "on";
      spaces                      = "on";
      dnd                         = "off";
      clock                       = "on";
      power                       = "on";
      padding_left                = 12;
      padding_right               = 12;
      spacing_left                = 14;
      spacing_right               = 18;
      text_font                   = ''"Iosevka SS05:Regular:12.0"'';
      icon_font                   = ''"Iosevka Nerd Font:Regular:12.0"'';
      background_color            = "0xff13141c";
      foreground_color            = "0xff565f89";
      power_icon_color            = "0xd09ece6a";
      battery_icon_color          = "0xd0e0af68";
      dnd_icon_color              = "0xff565f89";
      clock_icon_color            = "0xff565f89";
      power_icon_strip            = " ";
      space_icon                  = "";
      space_icon_strip            = "web dev msg read mu audio a b c d";
      spaces_for_all_displays     = "on";
      display_separator           = "on";
      display_separator_icon      = "";
      space_icon_color            = "0xffe0af68";
      space_icon_color_secondary  = "0xff78c4d4";
      space_icon_color_tertiary   = "0xfffff9b0";
      clock_icon                  = "";
      dnd_icon                    = "";
      clock_format                = ''"%a %B %e %I:%M"'';
      right_shell                 = "off";
      right_shell_icon            = "";
      right_shell_command         = "whoami";

      debug_output                = "off";
    };
  };

  launchd.user.agents.spacebar.serviceConfig.StandardErrorPath = "/tmp/spacebar.err.log";
  launchd.user.agents.spacebar.serviceConfig.StandardOutPath = "/tmp/spacebar.out.log";

  environment.etc."zshrc.local".text = builtins.readFile ./zshrc.local;
}
