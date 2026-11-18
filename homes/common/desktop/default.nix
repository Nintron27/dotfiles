# Graphical environment: Hyprland, bar, terminals, theming. Desktops only.
{ ... }:

{
  imports = [
    ./packages.nix
    ./alacritty.nix
    ./ghostty.nix
    ./hyprland
    ./dunst
    ./waybar
  ];

  # Enable finding installed fonts
  fonts.fontconfig.enable = true;

  catppuccin = {
    cursors.enable = true;
    cursors.accent = "light";

    brave.enable = true;
  };
  # catppuccin.cursors sets the cursor theme; enable generating its config.
  home.pointerCursor.enable = true;

  # gammastep
  services.gammastep = {
    enable = true;
    tray = true;

    dawnTime = "07:30";
    duskTime = "20:00";

    temperature = {
      day = 6000;
      night = 3300;
    };
  };


  # GTK 2/3
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

  catppuccin.rofi.enable = true;
  programs.rofi = {
    enable = true;
    # package = pkgs.rofi-wayland;

    settings = {
      modi = "drun";
      show-icons = true;
      display-drun = " Apps ";
      drun-display-format = "{icon} {name}";
      disable-history = false;
      hide-scrollbar = true;
    };
  };
}
