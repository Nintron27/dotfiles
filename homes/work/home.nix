{ pkgs, pkgs-unstable, ... }:
{
  imports = [
    (import ../common { inherit pkgs pkgs-unstable; username = "work"; } )
  ];
  # Autostart work apps on correct monitors
  hyprlandSettings.workAutostart = true;

  # Packages to install
  home.packages = with pkgs; [
    # development
    pkgs-unstable.shopify-cli
    handbrake
    ngrok

    # un-categorized packages
    openssl
    qpaeq
    chromium
    slack
    zoom-us

    # langservers
    nodePackages.svelte-language-server
  ];
}
