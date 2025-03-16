{ lib, config, pkgs, ... }:
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

      # This is where I would put my fonts, IF 25.05 DIDNT MOVE IT ON ME
      # fira-code
      # fira-code-symbols
      # nerd-fonts.fira-code
      # (nerdfonts.override { fonts = [ "FiraCode" ]; })

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
      nautilus
      localsend
      file-roller
      cheese
      gimp
      firefox
      brave
      yubikey-manager
      vesktop
      jdk17_headless
      obsidian
      darktable
      audacity

      # Development
      natscli
      nsc
      valkey
      gnumake
      git
      hey
      nodejs
      beekeeper-studio
      go_1_23
      deno
      # go-task
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
      # Temp removed, waiting on merge https://github.com/NixOS/nixpkgs/pull/384397
      # nodePackages.graphql-language-service-cli
      taplo # toml
      nodePackages.yaml-language-server # yaml
      lldb
      tailwindcss-language-server
      superhtml
      emmet-ls
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
      shopify-cli
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
