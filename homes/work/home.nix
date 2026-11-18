{ pkgs, lib, config, isArgentum, headless, inputs, ... }:
{
  imports = [
    (import ../common { inherit pkgs lib config inputs headless; username = "work"; } )
  ];
  packageConfiguration.enableWork = true;

  isArgentum = isArgentum;
}
// lib.optionalAttrs (!headless) {
  # Autostart work apps on correct monitors (Hyprland only exists on desktops)
  hyprlandSettings.workAutostart = true;
}
