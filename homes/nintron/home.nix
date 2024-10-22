{ pkgs, pkgs-unstable, lib, config, isArgentum, ... }:

{
  imports = [
    (import ../common { inherit pkgs pkgs-unstable lib config; username = "nintron"; } )
  ];

  packageConfiguration.enablePersonal = true;

  isArgentum = isArgentum;
}
