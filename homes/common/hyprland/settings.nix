# Hyprland settings, rendered by Home Manager as hl.* calls in hyprland.lua.
{ config, lib, ... }:
let
  lua = lib.generators.mkLuaInline;

  # keys is a Lua expression for the bind string. action is a Lua dispatcher expression.
  bind =
    keys: action: flags:
    {
      _args = [
        (lua keys)
        (lua action)
      ] ++ lib.optional (flags != null) flags;
    };

  key = k: ''"${k}"'';
  mod = k: ''mainMod .. " + ${k}"'';
  modShift = k: ''mainMod .. " + SHIFT + ${k}"'';

  exec = cmd: ''hl.dsp.exec_cmd("${cmd}")'';

  workspaceBinds = lib.concatLists (
    lib.genList (
      i:
      let
        keyName = if i == 9 then "0" else toString (i + 1);
        ws = toString (i + 1);
      in
      [
        (bind (mod keyName) ''hl.dsp.focus({ workspace = "${ws}" })'' null)
        (bind (modShift keyName) ''hl.dsp.window.move({ workspace = "${ws}" })'' null)
      ]
    ) 10
  );

  startupCommands = [
    ''hl.exec_cmd("hyprpaper")''
    ''hl.exec_cmd("waybar")''
  ]
  ++ lib.optional config.isArgentum ''hl.exec_cmd("blueman-applet")''
  ++ lib.optionals config.hyprlandSettings.workAutostart [
    ''hl.exec_cmd("brave", { workspace = "1 silent" })''
    ''hl.exec_cmd(terminal, { workspace = "2 silent" })''
  ];

  startup = ''
    function()
    ${lib.concatMapStrings (cmd: "\n      ${cmd}") startupCommands}
    end
  '';
in
{
  mainMod = {
    _var = "SUPER";
  };
  terminal = {
    _var = "ghostty +new-window";
  };

  monitor =
    if config.isArgentum then
      [
        {
          output = "eDP-1";
          mode = "2880x1920@120";
          position = "0x0";
          scale = 2;
        }
      ]
    else
      [
        {
          output = "DP-1";
          mode = "2560x1440@144";
          position = "0x0";
          scale = 1;
        }
        {
          output = "DP-2";
          mode = "1920x1080@143.85";
          position = "-1920x360";
          scale = 1;
        }
      ];

  env = [
    {
      _args = [
        "ELECTRON_OZONE_PLATFORM_HINT"
        "auto"
      ];
    }
  ];

  config =
    {
      general = {
        resize_on_border = true;
      } // lib.optionalAttrs config.isArgentum {
        gaps_in = 4;
        gaps_out = 8;
      };
      decoration = {
        rounding = 6;
        blur.enabled = false;
      };
      animations.enabled = false;
      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
      };
    }
    // lib.optionalAttrs (!config.isArgentum) {
      input.accel_profile = "flat";
    };

  # bindel/bindl/bindm are hyprlang keywords. Lua takes the same flags on hl.bind.
  bind =
    [
      (bind (mod "R") (exec "rofi -show drun") null)
      (bind (mod "RETURN") ''hl.dsp.exec_cmd(terminal)'' null)
      (bind (mod "Q") ''hl.dsp.window.close()'' null)
      (bind (mod "L") (exec "hyprlock") null)
      (bind (modShift "X") ''hl.dsp.exit()'' null)

      (bind (key "Print") ''hl.dsp.exec_cmd("grim -g \"$(slurp -d)\" - | wl-copy")'' null)

      (bind (mod "N") ''hl.dsp.focus({ direction = "left" })'' null)
      (bind (mod "E") ''hl.dsp.focus({ direction = "down" })'' null)
      (bind (mod "I") ''hl.dsp.focus({ direction = "up" })'' null)
      (bind (mod "O") ''hl.dsp.focus({ direction = "right" })'' null)

      (bind (mod "F") ''hl.dsp.window.fullscreen({ mode = "fullscreen" })'' null)
      (bind (modShift "F") ''hl.dsp.window.float({ action = "toggle" })'' null)

      (bind (modShift "N") ''hl.dsp.window.resize({ x = -32, y = 0, relative = true })'' null)
      (bind (modShift "E") ''hl.dsp.window.resize({ x = 0, y = 32, relative = true })'' null)
      (bind (modShift "I") ''hl.dsp.window.resize({ x = 0, y = -32, relative = true })'' null)
      (bind (modShift "O") ''hl.dsp.window.resize({ x = 32, y = 0, relative = true })'' null)
    ]
    ++ workspaceBinds
    ++ [
      (bind (key "XF86AudioRaiseVolume") (exec "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+") {
        locked = true;
        repeating = true;
      })
      (bind (key "XF86AudioLowerVolume") (exec "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-") {
        locked = true;
        repeating = true;
      })
      (bind (key "XF86AudioMute") (exec "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle") {
        locked = true;
        repeating = true;
      })
    ]
    ++ lib.optionals config.isArgentum [
      (bind (key "XF86MonBrightnessUp") (exec "brightnessctl s +5%") {
        locked = true;
        repeating = true;
      })
      (bind (key "XF86MonBrightnessDown") (exec "brightnessctl s 5%-") {
        locked = true;
        repeating = true;
      })
    ]
    ++ [
      (bind (key "XF86AudioPlay") (exec "playerctl play-pause") { locked = true; })
      (bind (key "XF86AudioNext") (exec "playerctl next") { locked = true; })
      (bind (key "XF86AudioPrev") (exec "playerctl previous") { locked = true; })
      (bind (modShift "S") (exec "systemctl suspend") { locked = true; })

      (bind (mod "mouse:272") ''hl.dsp.window.drag()'' { mouse = true; })
      (bind (mod "mouse:273") ''hl.dsp.window.resize()'' { mouse = true; })
    ];

  window_rule = [
    {
      match.class = "org.gnome.Nautilus";
      float = true;
    }
    {
      match.title = "Picture in picture";
      float = true;
      pin = true;
      size = "800 450";
      keep_aspect_ratio = true;
    }
  ];

  workspace_rule =
    if config.isArgentum then
      [
        {
          workspace = "1";
          monitor = "eDP-1";
          default = true;
        }
      ]
    else
      [
        {
          workspace = "1";
          monitor = "DP-1";
          default = true;
        }
        {
          workspace = "2";
          monitor = "DP-1";
        }
        {
          workspace = "3";
          monitor = "DP-1";
        }
        {
          workspace = "4";
          monitor = "DP-1";
        }
        {
          workspace = "5";
          monitor = "DP-1";
        }
        {
          workspace = "10";
          monitor = "DP-2";
          default = true;
        }
      ];

  on = [
    {
      _args = [
        "hyprland.start"
        (lua startup)
      ];
    }
  ];
}
