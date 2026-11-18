# Terminal packages, installed on every machine (desktops and arx).
# Graphical packages live in ../desktop/packages.nix.
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
      wireguard-tools

      # Random
      jrnl
      htop
      wget
      ffmpeg-full
      wcalc
      yubikey-manager
      jdk17_headless

      # Development
      github-cli
      sops # edit secrets/*.yaml
      age # age-keygen for the sops key
      ssh-to-age # convert SSH host keys to sops recipients
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

      deno
      gcc
      turso-cli
      flyctl
      spacetimedb
      sqlc

      podman-tui # status of containers in the terminal
      docker-compose # start group of containers for dev
      dive # look into docker image layers

      # langservers / Formatters
      nixd
      nixfmt
      prettier
      nil
      gopls # go
      rust-analyzer
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
    ];
  };
}
