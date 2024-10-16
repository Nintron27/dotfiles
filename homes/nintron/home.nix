{ pkgs, pkgs-unstable, ... }:

{
  imports = [
    (import ../common { inherit pkgs pkgs-unstable; username = "nintron"; } )
  ];
}
