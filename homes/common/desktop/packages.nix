# Graphical packages, installed on the desktops only (igneous, argentum).
# Terminal packages and the packageConfiguration options live in ../cli/packages.nix.
{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    # desktop stuff
    v4l-utils
    qpwgraph
    i3lock
    playerctl
    feh
    grim
    slurp
    wl-clipboard

    # This is where I would put my fonts, IF 25.05 DIDNT MOVE IT ON ME
    # fira-code
    # fira-code-symbols
    # nerd-fonts.fira-code
    # (nerdfonts.override { fonts = [ "FiraCode" ]; })

    # Random
    filezilla
    proton-vpn
    # mullvad-vpn
    # monero-gui
    vlc
    baobab
    pavucontrol
    gedit
    # gnome.gnome-screenshot
    nautilus
    localsend
    file-roller
    cheese
    gimp
    # firefox
    brave
    # chromium is built from source and is not in the binary cache right now.
    # chromium
    vesktop
    grok-bot
    obsidian
    darktable
    audacity
    spotify

    # Development
    # beekeeper-studio
    postman
    bruno
    vscodium
  ] ++ (if config.packageConfiguration.enablePersonal then [
    # sdrpp
    # rtl-sdr-osmocom
    # r2modman
    ledger-live-desktop
    signal-desktop
    feather
    prismlauncher
    obs-studio
  ] else []) ++ (if config.packageConfiguration.enableArgentum then [
    brightnessctl # Laptop only
  ] else []) ++ (if config.packageConfiguration.enableWork then [
    slack
    zoom-us
  ] else []);
}
