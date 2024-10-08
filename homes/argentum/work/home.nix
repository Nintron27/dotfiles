{ pkgs, pkgs-unstable, ... }:

{
  imports = [
    ../common
  ];
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "work";
  home.homeDirectory = "/home/work";

  home.stateVersion = "22.11";

  # Packages to install
  home.packages = with pkgs; [
    # development
    pkgs-unstable.shopify-cli
    handbrake
    ngrok

    # un-categorized packages
    openssl
    qpaeq
    chromium
    slack
    zoom-us

    # langservers
    nodePackages.svelte-language-server
  ];

  ###########################
  # Packages and/or Configs #
  ###########################

  # # window manager
  # xsession = {
  #   enable = true;
  
  #   windowManager.i3 = {
  #     enable = true;
  #     package = pkgs.i3-gaps;
  #     config = import ./config/i3/config.nix;
  #     # Startup my custom layout
  #     extraConfig = ''
  #       exec --no-startup-id "i3-msg 'workspace 1; append_layout /home/work/.i3/workspace-1.json'"
  #       exec --no-startup-id "i3-msg 'workspace 2; append_layout /home/work/.i3/workspace-2.json'"
  #       exec --no-startup-id "i3-msg 'workspace 3; append_layout /home/work/.i3/workspace-3.json'"
  #       exec --no-startup-id "i3-msg 'workspace 4; append_layout /home/work/.i3/workspace-4.json'"
  #       exec --no-startup-id "i3-msg 'workspace 5; append_layout /home/work/.i3/workspace-5.json'"
  #       exec --no-startup-id "i3-msg 'workspace 10; append_layout /home/work/.i3/workspace-10.json'"
  #       exec sleep 5 && brave
  #       exec sleep 5 && discord
  #       exec sleep 5 && spotify
  #       exec sleep 5 && slack
  #       exec sleep 5 && codium
  #       exec sleep 5 && obsidian
  #       exec sleep 5 && alacritty
  #       exec --no-startup-id "i3-msg workspace 1"
  #     '';
  #   };
  # };

  # # i3 workspaces
  # home.file.".i3" = {
  #   source = ./config/i3/workspaces;
  # };

  # # polybar
  # services.polybar = {
  #   enable = true;
  #   script = '''';
  # };
  # home.file.".config/polybar" = {
  #   source = ./config/polybar;
  # };


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
