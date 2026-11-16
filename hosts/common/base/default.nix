# Configuration shared by every machine (desktops and servers).
{ inputs, ... }:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.catppuccin.nixosModules.catppuccin

    ./nix.nix
    ./ssh.nix
    ./fish.nix
    ./catppuccin.nix
    ./networking.nix
    ./locale.nix
  ];
}
