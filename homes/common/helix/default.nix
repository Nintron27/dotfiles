{
  programs.helix = {
    enable = true;
    # catppuccin.enable = true; # Done below instead
  };
  home.file.".config/helix" = {
    source = ./config;
  };
}
