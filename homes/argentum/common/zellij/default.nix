{
  programs.zellij = {
    enable = true;
    # catppuccin.enable = true; #Done below instead
  };
  home.file.".config/zellij/config.kdl" = {
    source = ./config.kdl;
  };
}
