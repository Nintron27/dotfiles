{ pkgs, ... }:
{
  # Disable for now, as SDDM bug prevents environment variables
  # from being passed, so nothing works anyway, just use TTY to launch.
  services.displayManager.sddm = {
    enable = false;
    # catppuccin = {
    #   enable = true;
    #   font = "Fira Code";
    # };
    # Fix wrong Qt version
    package = pkgs.kdePackages.sddm;
  };
  
}
