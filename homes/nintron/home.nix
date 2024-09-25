{ inputs, config, pkgs, ... }:

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
