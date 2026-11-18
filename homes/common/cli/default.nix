# Terminal environment: shell, editor, dev tools. Used on every machine.
{ config, ... }:

{
  imports = [
    ./packages.nix
    ./git.nix
    ./agents
    ./helix
    ./zellij
    ./lf
  ];

  # catppuccin
  catppuccin = {
    autoEnable = true;
    enable = true;
    flavor = "mocha";
    accent = "mauve";
  };

  # fish
  catppuccin.fish.enable = true;
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
      export EDITOR=hx
      # Set PATH to add .local/bin
      export PATH="$PATH:${config.home.homeDirectory}/.local/bin"
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
}
