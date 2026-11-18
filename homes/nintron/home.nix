{ pkgs, lib, config, isArgentum, headless, inputs, ... }:

{
  imports = [
    (import ../common { inherit pkgs lib config inputs headless; username = "nintron"; } )
  ];

  packageConfiguration.enablePersonal = true;

  isArgentum = isArgentum;
}
