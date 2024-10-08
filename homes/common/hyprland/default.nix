{
  wayland.windowManager.hyprland = {
    enable = true;

    settings = import ./settings.nix;

    catppuccin.enable = true;
  };

  programs.hyprlock.enable = true;
  home.file.".config/hypr/hyprlock.conf".source = ./hyprlock/hyprlock.conf;
  home.file.".config/hypr/mocha.conf".source = ./hyprlock/mocha.conf;

  home.sessionVariables.NIXOS_OZONE_WL = "1";

  services.hyprpaper = {
    enable = true;
    settings = {
      splash = false;
      preload = "$HOME/.config/wallpaper.png";
      wallpaper = ", $HOME/.config/wallpaper.png";
    };
  };
}
