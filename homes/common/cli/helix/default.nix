{ ... }: {
  config = {
    catppuccin.helix.enable = false; # Done below instead
    programs.helix = {
      enable = true;
    };
    home.file.".config/helix" = {
      source = ./config;
    };
  };
}
