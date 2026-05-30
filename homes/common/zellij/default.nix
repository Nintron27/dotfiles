{ ... }:
{
  config = {
    catppuccin.zellij.enable = false; # Done below instead
    programs.zellij = {
      enable = true;
      enableFishIntegration = false;
    };
    home.file.".config/zellij/config.kdl" = {
      source = ./config.kdl;
    };
  };
}
