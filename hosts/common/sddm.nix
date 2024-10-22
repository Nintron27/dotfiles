{ pkgs, ... }:
{
  services.displayManager.sddm = {
    enable = true;
    catppuccin = {
      enable = true;
      font = "Fira Code";
    };
    # Fix wrong Qt version
    package = pkgs.kdePackages.sddm;
  };
  
}
