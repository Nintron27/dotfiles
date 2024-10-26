# All my Hyprland settings
{ config, lib, ...}: {
  # Monitors
  "monitor" = if config.isArgentum then [
    "eDP-1, 2880x1920@120, 0x0, 2"
  ] else [
    "DP-1, 2560x1440@144, 0x0, 1"
    "DP-2, 1920x1080@143.85, -1920x360, 1"
  ];

  # Env variables
  env = [
    "ELECTRON_OZONE_PLATFORM_HINT,auto"
  ];

  # Program keywords
  "$terminal" = "alacritty";

  # Startup actions
  "exec-once" = [
    "hyprpaper" # TODO: Unload preloaded after? idk
    "solaar -w hide"
    "waybar"
  ] ++ (if config.isArgentum then [
    "blueman-applet"
  ] else []) ++ (if config.hyprlandSettings.workAutostart then [
    "[workspace 1 silent] brave"
    "[workspace 2 silent] alacritty"
    "[workspace 3 silent] codium"
    "[workspace 4 silent] obsidian"
    "[workspace 5 silent] slack"
    "[workspace 10 silent] vesktop"
  ] else []);

  # Look & Feel
  general = {
    resize_on_border = true;
    gaps_in = lib.optionalAttrs config.isArgentum 4;
    gaps_out = lib.optionalAttrs config.isArgentum 8;
  };
  decoration = {
    rounding = 6;

    blur = {
      enabled = false;
    };
  };
  animations = {
    enabled = false;
  };

  # Input
  input = lib.optionalAttrs (!config.isArgentum) {
    accel_profile = "flat";
  };

  # Keybindings
  "$mainMod" = "SUPER";

  bind = [
    "$mainMod, r, exec, rofi -show drun"
    "$mainMod, Return, exec, alacritty"
    "$mainMod, q, killactive"
    "$mainMod, l, exec, hyprlock"
    "$mainMod SHIFT, x, exit"

    # Shortcuts
    ", Print, exec, grim -g \"$(slurp -d)\" - | wl-copy"

    # Move focus
    "$mainMod, n, movefocus, l"
    "$mainMod, e, movefocus, d"
    "$mainMod, i, movefocus, u"
    "$mainMod, o, movefocus, r"

    # Window manipulation
    "$mainMod, f, fullscreen, 0"
    "$mainMod SHIFT, f, togglefloating"

    "$mainMod SHIFT, n, resizeactive, -32 0"
    "$mainMod SHIFT, e, resizeactive, 0 32"
    "$mainMod SHIFT, i, resizeactive, 0 -32"
    "$mainMod SHIFT, o, resizeactive, 32 0"

    # Switch workspace
    "$mainMod, 1, workspace, 1"
    "$mainMod, 2, workspace, 2"
    "$mainMod, 3, workspace, 3"
    "$mainMod, 4, workspace, 4"
    "$mainMod, 5, workspace, 5"
    "$mainMod, 6, workspace, 6"
    "$mainMod, 7, workspace, 7"
    "$mainMod, 8, workspace, 8"
    "$mainMod, 9, workspace, 9"
    "$mainMod, 0, workspace, 10"

    # Move active window to workspace [0-9]
    "$mainMod SHIFT, 1, movetoworkspace, 1"
    "$mainMod SHIFT, 2, movetoworkspace, 2"
    "$mainMod SHIFT, 3, movetoworkspace, 3"
    "$mainMod SHIFT, 4, movetoworkspace, 4"
    "$mainMod SHIFT, 5, movetoworkspace, 5"
    "$mainMod SHIFT, 6, movetoworkspace, 6"
    "$mainMod SHIFT, 7, movetoworkspace, 7"
    "$mainMod SHIFT, 8, movetoworkspace, 8"
    "$mainMod SHIFT, 9, movetoworkspace, 9"
    "$mainMod SHIFT, 0, movetoworkspace, 10"

  ];

  bindel = [
    # Volume
    ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
    ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
    ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
  ] ++ (if config.isArgentum then [
    ", XF86MonBrightnessUp, exec, brightnessctl s +5%"
    ", XF86MonBrightnessDown, exec, brightnessctl s 5%-"
  ] else []);
  bindl = [
    # Playerctl
    ", XF86AudioPlay, exec, playerctl play-pause"
    ", XF86AudioNext, exec, playerctl next"
    ", XF86AudioPrev, exec, playerctl previous"

    "$mainMod SHIFT, s, exec, systemctl suspend"
  ];

  # Mouse binds
  bindm = [
    "$mainMod, mouse:272, movewindow"
    "$mainMod, mouse:273, resizewindow"
  ];

  # Window Rules
  windowrulev2 = [
    "float, class:(org.gnome.Nautilus)"

    # Picture in picture
    "float, title:(Picture in picture)"
    "pin, title:(Picture in picture)"
    "size 800 450, title:(Picture in picture)"
    "keepaspectratio, title:(Picture in picture)"
  ];

  # Workspace
  workspace = (if config.isArgentum then [
    "1, monitor:eDP-1, default:true"
  ] else [
    "1, monitor:DP-1, default:true"
    "2, monitor:DP-1"
    "3, monitor:DP-1"
    "4, monitor:DP-1"
    "5, monitor:DP-1"
    "10, monitor:DP-2, default:true"
  ]);

  misc = {
    disable_hyprland_logo = true;
    disable_splash_rendering = true;
  };
}
