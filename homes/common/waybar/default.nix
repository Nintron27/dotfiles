{
  programs.waybar = {
    enable = true;
    catppuccin.enable = true;

    settings = {
      primary = {
        layer = "top";
        output = ["DP-1"];
        # height = 32;
        # margin = "12 20 0";
        # margin-bottom = 0;
        spacing = 10;
        modules-left = [
          "hyprland/workspaces"
          "mpris"
        ];

        modules-center = [
          "clock"
        ];

        modules-right = [
          "privacy"
          "pulseaudio"
          "network"
          "tray"
        ];

        "hyprland/workspaces" = {
          all-outputs = true;
        };
        mpris = {
          format = "󰎇 {title} - {artist}";
          format-paused = " ";
        };
        clock = {
          interval = 1;
          format = "{:%H:%M:%S %d/%m/%Y}";
        };
        privacy = {
          icon-size = 18;
        };
        pulseaudio = {
          format = "{icon} {volume}%";
          format-bluetooth = "󰂰 {volume}%";
          format-muted = "";
          format-icons = [
            ""
            ""
            ""
          ];
        };
        network = {
          interval = 5;
          format = "{icon}";
          format-wifi = "{icon} {essid}";
          format-icons = {
            "wifi" = "󰀂";
            "ethernet" = "󰱓";
            "disconnected" = "󰅛";
            "disabled" = "󰅛";
          };
        };
        tray = {
          icon-size = 20;
          spacing = 8;
          show-passive-items = true;
        };
      };
    };

    style = ''
      * {
          font-family: FiraCode Nerd Font;
          font-size: 16px;
      }

      #workspaces button {
        border-radius: 0px;
      }
      #workspaces button.active {
        background-color: @surface1;
      }
      #workspaces button.urgent {
        background-color: @red;
        color: @crust;
      }

      #mpris {
        margin-left: 6px;
        color: @green;
        font-size: 14px;
      }

      .modules-right {
        margin-right: 8px;
      }

      #privacy {
        color: @red;
      }

      #pulseaudio {
        font-size: 18px;
        color: @sky;
      }
      #pulseaudio.muted {
        color: @red;
        padding-right: 10px;
      }

      #network {
        background-color: @surface0;
        border-radius: 4px;
        margin: 4px 0;

        padding: 0 8px;
        padding-right: 11px;
        font-size: 18px;
        color: @sky;
      }
      #network.disabled,#network.disconnected {
        color: @red;
      }

      #tray {
        background-color: @surface0;
        border-radius: 4px;
        padding: 0 8px;
        margin: 4px 0;
      }
    '';
  };
}
