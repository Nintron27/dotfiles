{ pkgs, lib, config, isArgentum, inputs, ... }:
{
  imports = [
    (import ../common { inherit pkgs lib config inputs; username = "work"; } )
  ];
  # Autostart work apps on correct monitors
  hyprlandSettings.workAutostart = true;

  packageConfiguration.enableWork = true;

  isArgentum = isArgentum;
}
