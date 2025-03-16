{
  programs.zellij = {
    enable = true;
    enableFishIntegration = false;
    # catppuccin.enable = true; #Done below instead
  };
  home.file.".config/zellij/config.kdl" = {
    source = ./config.kdl;
  };
}
