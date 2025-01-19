{ 
  inputs,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.catppuccin.nixosModules.catppuccin

    ./nix.nix
    ./hyprland.nix
    ./sddm.nix
    ./fonts.nix
    ./fish.nix
    ./catppuccin.nix
    ./networking.nix
    ./pipewire.nix
    ./zsa-board.nix
    ./bluetooth.nix
  ];
}
