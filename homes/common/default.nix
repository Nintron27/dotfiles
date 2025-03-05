{ pkgs, lib, username, ... }:

{
  imports = [
    ./packages.nix
    ./alacritty.nix
    ./hyprland
    ./dunst
    ./waybar
    ./helix
    ./zellij
    ./lf
  ];

  options.isArgentum = lib.mkOption {
    default = false;
    type = lib.types.bool;
    description = ''
      Enable all package/feature related settings to Argentum
    '';
  };

  config = {
    home.stateVersion = "23.11";

    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.allowBroken= true;

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;

    home.username = username;
    home.homeDirectory = "/home/${username}";

    # Enable finding installed fonts
    fonts.fontconfig.enable = true;

    # catppuccin
    catppuccin = {
      flavor = "mocha";
      accent = "mauve";

      cursors.enable = true;
      cursors.accent = "light";
    };

    # gammastep
    services.gammastep = {
      enable = true;
      tray = true;

      dawnTime = "07:30";
      duskTime = "20:00";

      temperature = {
        day = 6000;
        night = 3700;
      };
    };


    # GTK 2/3
    catppuccin.gtk.enable = true;
    gtk = {
      enable = true;
    };

    # QT, sadly breaks XDPH currently
    # qt = {
    #   enable = true;
    #   platformTheme.name = "kvantum";
    #   style.name = "kvantum";
    #   style.catppuccin.enable = true;
    # };

    # TODO: check this later for clean up of other stuff >>> programs.rofi =  import ./config/rofi/config.nix;
    catppuccin.rofi.enable = true;
    programs.rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
  
      extraConfig = {
        modi = "drun";
        show-icons = true;
        display-drun = " Apps ";
        drun-display-format = "{icon} {name}";
        disable-history = false;
        hide-scrollbar = true;
      };
    };

    # fish
    catppuccin.fish.enable = true;
    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting # Disable greeting
        export EDITOR=hx
        # Set PATH to add .local/bin
        export PATH="$PATH:/home/${username}/.local/bin"
      '';
    };

    # direnv
    programs.direnv.enable = true;
    programs.direnv.nix-direnv.enable = true;

    # starship
    catppuccin.starship.enable = true;
    programs.starship = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        add_newline = false;
      };
    };


    catppuccin.lazygit.enable = true;
    programs.lazygit = {
      enable = true;
      settings = { };
    };

    # custom scripts
    home.file.".local/bin" = {
      source = ./scripts;
    };
  };
}
