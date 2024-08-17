{ config, pkgs, ... }:

# let
  # customNodePackages = import ./pkgs/nodePackages/default.nix {};
# in
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "nintron";
  home.homeDirectory = "/home/nintron";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowBroken= true;
  # nixpkgs.config = {
  #   allowUnfree = true;
  #   packageOverrides = pkgs: {
  #     polybar = pkgs.polybar.override {
  #       i3Support = true;
  #       pulseSupport = true;
  #     };
  #   };
  # };

  
  # Enable finding installed fonts
  fonts.fontconfig.enable = true;

  # Packages to install
  home.packages = with pkgs; [
    # fonts
    fira-code
    fira-code-symbols
    (nerdfonts.override { fonts = [ "FiraCode" ]; })

    # desktop stuff
    qpwgraph
    i3lock
    playerctl
    feh

    # development
    gnumake
    git
    hey
    nodejs
    beekeeper-studio
    go
    go-migrate
    air
    goose
    gcc
    sqld
    postman
    turso-cli
    flyctl
    bruno
    lf
    cargo-generate
    sqlc
    vscodium
    tigerbeetle

    # un-categorized packages
    htop
    mullvad-vpn
    monero-gui
    wget
    vlc
    ffmpeg-full
    baobab
    spotify
    pavucontrol
    neofetch
    wcalc
    gedit
    gnome.gnome-screenshot
    gnome.nautilus
    gnome.file-roller
    gnome.cheese
    gimp
    firefox
    brave
    yubikey-manager
    feather
    sdrpp
    rtl-sdr-osmocom
    signal-desktop
    discord
    r2modman
    # slack
    jdk17_headless
    minecraft
    prismlauncher
    obsidian
    obs-studio
    filezilla
    gparted

    # langservers / Formatters
    nodePackages.prettier
    nil
    gopls # go
    nodePackages.typescript-language-server
    nodePackages.vscode-langservers-extracted
    # customNodePackages.svelte-language-server
    # customNodePackages."@tailwindcss/language-server"
    nodePackages.graphql-language-service-cli
    # python39Packages.pylsp-mypy
    taplo # toml
    nodePackages.yaml-language-server # yaml
    lldb
  ];

  
  ###########################
  # Packages and/or Configs #
  ###########################

  # window manager
  xsession = {
    enable = true;
  
    windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;
      config = import ./config/i3/config.nix;
    };
  };

  # catppuccin
  catppuccin = {
    flavor = "mocha";
    accent = "mauve";

    pointerCursor.enable = true;
    pointerCursor.accent = "light";
  };

  # polybar
  services.polybar = {
    enable = true;
    script = '''';
    package = pkgs.polybar.override {
      i3Support = true;
      pulseSupport = true;
    };
  };
  home.file.".config/polybar" = {
    source = ./config/polybar;
  };

  # dunst
  services.dunst = {
    enable = true;
    catppuccin.enable = true;
    configFile = ./config/dunst/dunstrc;
  };

  # redshift
  services.redshift = {
    enable = true;
    tray = true;

    dawnTime = "07:30";
    duskTime = "20:45";

    temperature = {
      day = 5500;
      night = 3700;
    };
  };

  # GTK 2/3
  gtk = {
    enable = true;
    catppuccin.enable = true;
  };

  # application launcher
  # TODO: check this later for clean up of other stuff >>> programs.rofi =  import ./config/rofi/config.nix;
  programs.rofi = {
    enable = true;
    catppuccin.enable = true;
    #terminal = "${pkgs.alacritty}/bin/alacritty";
    # theme = ./catppuccin-mocha.rasi;
  
    extraConfig = {
      modi = "drun";
      show-icons = true;
      display-drun = " Apps ";
      drun-display-format = "{icon} {name}";
      disable-history = false;
      hide-scrollbar = true;
    };
  };

  # direnv
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
 
  # fish
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
      export EDITOR=hx
      # Set PATH to add .local/bin
      export PATH="$PATH:/home/nintron/.local/bin"
    '';

    catppuccin.enable = true;
  };
  
  # starship
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      add_newline = false;
    };
    catppuccin.enable = true;
  };

  # alacritty
  programs.alacritty = {
    enable = true;

    catppuccin.enable = true;

    settings = {
      window.padding = {
        x = 6;
        y = 6;
      };
      font = {
        size = 14;

        normal = {
          family = "Fira Code";
          style = "Regular";
        };
        bold = {
          family = "Fira Code";
          style = "Bold";
        };
        bold_italic = {
          family = "Fira Code";
          style = "Bold Italic";
        };
        italic = {
          family = "Fira Code";
          style = "Italic";
        };
      };
    };
  };

  # helix
  programs.helix = {
    enable = true;
    # catppuccin.enable = true; # Done below instead
  };
  home.file.".config/helix" = {
    source = ./config/helix;
  };

  # zellij
  programs.zellij = {
    enable = true;
    # catppuccin.enable = true; #Done below instead
  };
  home.file.".config/zellij/config.kdl" = {
    source = ./config/zellij/config.kdl;
  };

  programs.lazygit = {
    enable = true;
    catppuccin.enable = true;
  };

  # lf
  home.file.".config/lf/lfrc" = {
    source = ./config/lf/lfrc;
  };

  # custom scripts
  home.file.".local/bin" = {
    source = ./scripts;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
