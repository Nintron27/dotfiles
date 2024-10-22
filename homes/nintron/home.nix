{ pkgs, pkgs-unstable, lib, ... }:

{
  imports = [
    (import ../common { inherit pkgs pkgs-unstable lib; username = "nintron"; } )
  ];

  packageConfiguration.enablePersonal = true;
}
