{ pkgs, lib, config, isArgentum, inputs, ... }:

{
  imports = [
    (import ../common { inherit pkgs lib config inputs; username = "nintron"; } )
  ];

  packageConfiguration.enablePersonal = true;

  isArgentum = isArgentum;
}
