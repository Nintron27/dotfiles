{ lib, config, pkgs, pkgs-unstable, ... }:
{
  options.packageConfiguration = {
    enablePersonal = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = ''
        Enable personal profile specific packages, such as games
      '';
    };
    enableArgentum = lib.mkOption {
      default = config.isArgentum;
      type = lib.types.bool;
      description = ''
        Enable argentum specific packages
      '';
    };
    enableWork = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = ''
        Enable work specific packages
      '';
    };
  };

  config = {
    home.packages = with pkgs; [
      # desktop stuff
      qpwgraph
      i3lock
      playerctl
      feh
      grim
      slurp
      wl-clipboard
      wireguard-tools

      # fonts
      fira-code
      fira-code-symbols
      (nerdfonts.override { fonts = [ "FiraCode" ]; })

      # Random
      filezilla
      htop
      # mullvad-vpn
      # monero-gui
      wget
      vlc
      ffmpeg-full
      baobab
      pavucontrol
      neofetch
      wcalc
      gedit
      # gnome.gnome-screenshot
      gnome.nautilus
      gnome.file-roller
      gnome.cheese
      gimp
      firefox
      brave
      yubikey-manager
      vesktop
      jdk17_headless
      obsidian

      # Development
      natscli
      nsc
      pkgs-unstable.valkey
      gnumake
      git
      hey
      nodejs
      beekeeper-studio
      go
      go-migrate
      gcc
      postman
      turso-cli
      flyctl
      bruno
      sqlc
      vscodium

      # langservers / Formatters
      nodePackages.prettier
      nil
      gopls # go
      nodePackages.typescript-language-server
      nodePackages.vscode-langservers-extracted
      nodePackages.svelte-language-server
      nodePackages.graphql-language-service-cli
      taplo # toml
      nodePackages.yaml-language-server # yaml
      lldb
    ] ++ (if config.packageConfiguration.enablePersonal then [
      # sdrpp
      # rtl-sdr-osmocom
      # r2modman
      signal-desktop
      feather
      minecraft
      prismlauncher
      obs-studio
    ] else []) ++ (if config.packageConfiguration.enableArgentum then [
      brightnessctl # Laptop only
    ] else []) ++ (if config.packageConfiguration.enableWork then [
      # development
      pkgs-unstable.shopify-cli
      handbrake
      ngrok

      # un-categorized packages
      openssl
      chromium
      slack
      zoom-us
    ] else []);
  };
}
