{
  enable = true;
  #terminal = "${pkgs.alacritty}/bin/alacritty";
  theme = ./catppuccin-mocha.rasi;
  
  extraConfig = {
    modi = "drun";
    show-icons = true;
    display-drun = " Apps ";
    drun-display-format = "{icon} {name}";
    disable-history = false;
    hide-scrollbar = true;
  };
}
