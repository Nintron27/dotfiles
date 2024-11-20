{ pkgs, lib, config, isArgentum, ... }:

{
  imports = [
    (import ../common { inherit pkgs lib config; username = "nintron"; } )
  ];

  packageConfiguration.enablePersonal = true;

  isArgentum = isArgentum;
}
