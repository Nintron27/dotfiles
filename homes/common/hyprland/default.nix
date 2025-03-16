{ lib, config, ...}:
{
  options.hyprlandSettings = {
    workAutostart = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = ''
        Enable autostart applications for work profile
      '';
    };
  };

  config = {
    catppuccin.hyprland.enable = true;
    wayland.windowManager.hyprland = {
      enable = true;

      settings = import ./settings.nix { inherit config lib; };
    };

    # Conditional left, as Hyprland cursor seems to be too big now on v45
    home.pointerCursor.size = if config.isArgentum then 24 else 24;

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
    # TODO: Fix hypridle on desktop, currently borked
    services.hypridle = lib.optionalAttrs config.isArgentum {
      enable = true;
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
        };

        listener = lib.optionalAttrs config.isArgentum [
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
  };
}
