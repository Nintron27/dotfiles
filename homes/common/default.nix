{ pkgs, ... }:

{
  imports = [
    ./alacritty.nix
    ./helix
    ./zellij
    ./lf
  ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowBroken= true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Enable finding installed fonts
  fonts.fontconfig.enable = true;

  # catppuccin
  catppuccin = {
    flavor = "mocha";
    accent = "mauve";

    pointerCursor.enable = true;
    pointerCursor.accent = "light";
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

  # TODO: check this later for clean up of other stuff >>> programs.rofi =  import ./config/rofi/config.nix;
  programs.rofi = {
    enable = true;
    catppuccin.enable = true;
  
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

  # starship
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      add_newline = false;
    };
    catppuccin.enable = true;
  };

  programs.lazygit = {
    enable = true;
    catppuccin.enable = true;
  };

  # custom scripts
  home.file.".local/bin" = {
    source = ./scripts;
  };

  home.packages = with pkgs; [
    # desktop stuff
    qpwgraph
    i3lock
    playerctl
    feh

    # fonts
    fira-code
    fira-code-symbols
    (nerdfonts.override { fonts = [ "FiraCode" ]; })

    # Random
    filezilla
    htop
    spotify
    mullvad-vpn
    monero-gui
    wget
    vlc
    ffmpeg-full
    baobab
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

    # Development
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
    cargo-generate
    sqlc
    vscodium
    tigerbeetle

    
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
}