{ pkgs, lib, config, isArgentum, ... }:
{
  imports = [
    (import ../common { inherit pkgs lib config; username = "work"; } )
  ];
  # Autostart work apps on correct monitors
  hyprlandSettings.workAutostart = true;

  packageConfiguration.enableWork = true;

  isArgentum = isArgentum;
}
