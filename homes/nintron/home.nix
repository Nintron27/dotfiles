{ config, pkgs, ... }:

{
  imports = [
    ../common
  ];

  home.username = "nintron";
  home.homeDirectory = "/home/nintron";

  home.stateVersion = "23.11";

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
}
