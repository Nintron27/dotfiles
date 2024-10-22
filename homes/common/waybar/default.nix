{ config, ... }:
{
  config = {
    programs.waybar = {
      enable = true;
      catppuccin.enable = true;

      settings = (if config.isArgentum then {
        primary = {
          layer = "top";
          output = ["eDP-1"];
          # height = 32;
          margin = "8 8 0";
          # margin-bottom = 0;
          spacing = 6;
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
            "backlight"
            "battery"
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
            icon-size = 14;
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
            icon-size = 14;
            spacing = 4;
            show-passive-items = true;
          };
          backlight = {
            interval = 60;
            tooltip = false;
            format = "{percent}% {icon}";
            format-icons = [ "󰃞" "󰃠" ];
          };
          battery = {
            format = "{capacity}% {icon}";
            format-charging = "{capacity}% ";
            interval = 10;
            tooltip-format = "{power}W - {timeTo}";
            states = {
              full = 100;
              high = 75;
              mid = 50;
              low = 20;
              critical = 10;
            };
            format-icons = { 
              critical ="";
              low = "";
              mid = "";
              high = "";
              full = "";
            };
          };
        };
      } else {
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
      });

      style = (if !config.isArgentum then ''
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
      '' else ''
        * {
            font-family: FiraCode Nerd Font;
            font-size: 12px;
        }

        #waybar {
          border-radius: 6px;
        }

        #workspaces button {
          padding: 2px 4px;
          border-radius: 6px;
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
          margin-top: 2px;
          color: @green;
          font-size: 10px;
        }

        #clock {
          padding: 2px 0 0;
        }

        .modules-right {
          margin-right: 8px;
        }

        #privacy {
          padding: 2px 0 0;
          color: @red;
        }

        #pulseaudio {
          font-size: 12px;
          color: @sky;
          padding: 2px 0 0;
        }
        #pulseaudio.muted {
          color: @red;
          padding-right: 10px;
        }

        #network {
          background-color: @surface0;
          border-radius: 4px;
          margin: 4px 0;

          padding: 2px 6px 0;
          padding-right: 9px;
          font-size: 14px;
          color: @sky;
        }
        #network.disabled,#network.disconnected {
          color: @red;
        }

        #tray {
          background-color: @surface0;
          border-radius: 4px;
          padding: 2px 6px 0;
          margin: 4px 0;
        }
        #backlight {
          color: @yellow;
          padding: 2px 4px 0 0;
        }
        #battery {
          color: @text;
          padding: 2px 7px 0 0;
        }
        #battery.low, #battery.critical {
          color: @red;
        }
        #battery.charging {
          color: @green;
        }
      '');
    };
  };
}
