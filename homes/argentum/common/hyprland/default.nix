{
  wayland.windowManager.hyprland = {
    enable = true;

    settings = import ./settings.nix;

    catppuccin.enable = true;
  };
  home.pointerCursor.size = 24;

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
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };

      listener = [
        {
          timeout = 300; # 300
          on-timeout = "brightnessctl -s set 0";
          on-resume = "brightnessctl -r";
        }
        {
          timeout = 330;
          on-timeout = "systemctl suspend-then-hibernate";
        }
      ];
    };
  };
}