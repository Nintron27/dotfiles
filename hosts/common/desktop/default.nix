# Configuration for graphical machines (igneous, argentum).
{
  imports = [
    ./virtualisation.nix
    ./hyprland.nix
    ./sddm.nix
    ./fonts.nix
    ./pipewire.nix
    ./zsa-board.nix
    ./bluetooth.nix
    ./arx-client.nix
    ./fido.nix
  ];

  # Hytale's Linux launcher is a Flatpak bundle from accounts.hytale.com.
  services.flatpak.enable = true;
}
