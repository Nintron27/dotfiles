{ pkgs, pkgs-unstable, lib, ... }:
{
  imports = [
    (import ../common { inherit pkgs pkgs-unstable lib; username = "work"; } )
  ];
  # Autostart work apps on correct monitors
  hyprlandSettings.workAutostart = true;

  packageConfiguration.enableWork = true;
}
