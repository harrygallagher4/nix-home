{ config, pkgs, lib, xdg, ... }:
let
  tmp_directory = "/tmp";
  home_directory = "${config.home.homeDirectory}";
in
rec {
  imports = [ ];

  home.packages = with pkgs; [
    bat
    cachix
    cointop
    coreutils
    curl
    exa
    fd
    findutils
    fzf
    fontforge
    gnugrep
    gnused
    luajit
    # neovim-remote
    niv
    nixpkgs-fmt
    # nodePackages.node2nix
    # nodePackages.vim-language-server
    pet
    renameutils
    ripgrep
    rnix-lsp
    shfmt
    zulip-term
  ];

  home = {
    stateVersion = "20.09";

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      PAGER = "less";
      XDG_CACHE_HOME = xdg.cacheHome;
      XDG_CONFIG_HOME = xdg.configHome;
      XDG_DATA_HOME = xdg.dataHome;
    };
  }; #// home

  programs = {
    home-manager.enable = true;

    direnv = {
      enable = true;
      enableZshIntegration = true;
      stdlib = builtins.readFile ./direnvrc;
      nix-direnv = {
        enable = true;
        enableFlakes = true;
      };
    }; #// programs.direnv

    exa = {
      enable = true;
      enableAliases = true;
    }; #// programs.exa

    fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultCommand = "${pkgs.fd}/bin/fd --hidden --type=f";
      defaultOptions = [ "--reverse" ];
    }; #// programs.fzf

    lf = {
      enable = true;
      previewer.source = ./lf-previewer.sh;

      settings = {
        ratios = "4:6:7";
        icons = true;
        incsearch = true;
      };

      commands = {
        open = "&nvr --nostart -o $fx";
        ncd = ''&nvr +"cd $PWD"'';
      };

      keybindings = {
        "<c-n>" = "ncd";
        "D" = "delete";
      };

      cmdKeybindings = {
        "<tab>" = "cmd-menu-complete";
        "<s-tab>" = "cmd-menu-complete-back";
      };

      extraConfig = ''
        set hiddenfiles .*:!.config:!.zshrc:!.zshenv:!.zfunc:!.editorconfig:!.nix
      '';
    }; #// programs.lf

    man = {
      enable = true;
      generateCaches = true;
    }; #// programs.man
  }; #// programs

  programs.zsh = {
    enable = true;

    initExtraFirst = builtins.readFile ./zshrc-head.zsh;
    initExtraBeforeCompInit = builtins.readFile ./zshrc-plugins.zsh;
    initExtra = builtins.readFile ./zshrc.zsh;
    envExtra = builtins.readFile ./zshenv.zsh;

    shellAliases = {
      rm = "trash";
      nvim = "${pkgs.neovim-remote}/bin/nvr -s";
      ncd = "${pkgs.neovim-remote}/bin/nvr +\"cd $PWD\"";
      sp = "${pkgs.neovim-remote}/bin/nvr -o";
      vsp = "${pkgs.neovim-remote}/bin/nvr -O";
      vim = "nvim";
      lynx = "TERM='xterm-kitty' lynx";
      tabicons = "kitty @ set-tab-title -m 'title:^\\(z\\)\$' ' ' && kitty @ set-tab-title -m 'title:^\\(v\\)\$' ' '";
      ntab = "kitty @ launch --type=tab --title=' ' --copy-env zsh -c '${pkgs.neovim-remote}/bin/nvr -s'";
      mstat = "/usr/bin/stat";
      msed = "/usr/bin/sed";
    };

    history = {
      size = 50000;
      save = 999999;
      ignoreDups = true;
      ignoreSpace = true;
      expireDuplicatesFirst = true;
      share = true;
      extended = true;
    };
  }; #// programs.zsh

  home.activation.fixZshrcCompinit = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    zshrcPath="$(${pkgs.coreutils}/bin/readlink ${home_directory}/.zshrc)"
    sudo ${pkgs.gnused}/bin/sed -i '/^autoload -U compinit && compinit$/d' "$zshrcPath"
  '';

  xdg = {
    enable = true;

    configHome = "${home_directory}/.config";
    dataHome = "${home_directory}/.local/share";
    cacheHome = "${home_directory}/.cache";
  };
}
