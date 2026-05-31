{ lib, config, pkgs, inputs, ... }:
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
      v4l-utils
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
      jrnl
      htop
      proton-vpn
      # mullvad-vpn
      # monero-gui
      wget
      vlc
      ffmpeg-full
      baobab
      pavucontrol
      wcalc
      gedit
      # gnome.gnome-screenshot
      nautilus
      localsend
      file-roller
      cheese
      gimp
      # firefox
      brave
      chromium
      yubikey-manager
      vesktop
      jdk17_headless
      obsidian
      darktable
      audacity
      spotify

      # Development
      (inputs.jailed-agents.lib.${pkgs.system}.makeJailedPi { name = "pi"; })
      (inputs.jailed-agents.lib.${pkgs.system}.makeJailedOpencode { name = "opencode"; })
      valkey
      git
      gnumake
      hey
      nsc
      natscli
      steam-run
      nodejs

      # go-task
      go-migrate
      go

      # beekeeper-studio
      deno
      gcc
      postman
      turso-cli
      flyctl
      bruno
      sqlc
      vscodium

      podman-tui # status of containers in the terminal
      docker-compose # start group of containers for dev
      dive # look into docker image layers

      # langservers / Formatters
      nixd
      nixfmt
      prettier
      nil
      gopls # go
      typescript-language-server
      vscode-langservers-extracted
      svelte-language-server
      # Temp removed, waiting on merge https://github.com/NixOS/nixpkgs/pull/384397
      # nodePackages.graphql-language-service-cli
      taplo # toml
      yaml-language-server # yaml
      lldb
      tailwindcss-language-server
      superhtml
      emmet-ls
    ] ++ (if config.packageConfiguration.enablePersonal then [
      # sdrpp
      # rtl-sdr-osmocom
      # r2modman
      ledger-live-desktop
      signal-desktop
      feather
      prismlauncher
      obs-studio
    ] else []) ++ (if config.packageConfiguration.enableArgentum then [
      brightnessctl # Laptop only
    ] else []) ++ (if config.packageConfiguration.enableWork then [
      # development
      # shopify-cli
      handbrake
      ngrok

      # un-categorized packages
      openssl
      slack
      zoom-us
    ] else []);
  };
}
