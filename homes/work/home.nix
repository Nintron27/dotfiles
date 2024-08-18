{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "work";
  home.homeDirectory = "/home/work";

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

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Enable finding installed fonts
  fonts.fontconfig.enable = true;
  
  # Packages to install
  home.packages = with pkgs; [
    # fonts
    fira-code
    fira-code-symbols
    (nerdfonts.override { fonts = [ "FiraCode" ]; })

    # desktop stuff
    i3lock
    playerctl
    feh

    # development
    git
    # postman
    hey
    nodejs
    handbrake
    nodePackages.prettier
    lf
    mongodb-compass
    ngrok
    mullvad-vpn

    turso-cli
    bruno
    go
    vscodium
    flyctl
    wasmtime

    # un-categorized packages
    htop
    vlc
    ffmpeg-full
    baobab
    qpaeq
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
    chromium
    brave
    discord
    betterdiscordctl
    slack
    obsidian
    zoom-us

    # langservers
    nil
    gopls
    nodePackages.typescript-language-server
    nodePackages.vscode-langservers-extracted
    nodePackages.svelte-language-server
    # customNodePackages."@tailwindcss/language-server"
    nodePackages.graphql-language-service-cli
    # python39Packages.pylsp-mypy
    taplo
    nodePackages.yaml-language-server
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
      # Startup my custom layout
      extraConfig = ''
        exec --no-startup-id "i3-msg 'workspace 1; append_layout /home/work/.i3/workspace-1.json'"
        exec --no-startup-id "i3-msg 'workspace 2; append_layout /home/work/.i3/workspace-2.json'"
        exec --no-startup-id "i3-msg 'workspace 3; append_layout /home/work/.i3/workspace-3.json'"
        exec --no-startup-id "i3-msg 'workspace 4; append_layout /home/work/.i3/workspace-4.json'"
        exec --no-startup-id "i3-msg 'workspace 5; append_layout /home/work/.i3/workspace-5.json'"
        exec --no-startup-id "i3-msg 'workspace 10; append_layout /home/work/.i3/workspace-10.json'"
        exec sleep 5 && brave
        exec sleep 5 && discord
        exec sleep 5 && spotify
        exec sleep 5 && slack
        exec sleep 5 && codium
        exec sleep 5 && obsidian
        exec sleep 5 && alacritty
        exec --no-startup-id "i3-msg workspace 1"
      '';
    };
  };

  # i3 workspaces
  home.file.".i3" = {
    source = ./config/i3/workspaces;
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

    dawnTime = "06:15";
    duskTime = "19:45";

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
}
