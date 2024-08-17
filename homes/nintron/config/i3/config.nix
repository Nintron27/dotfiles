{
  modifier = "Mod4";
  bars = [ ]; # use polybar instead

  floating = {
    titlebar = false;
  };
  window = {
    titlebar = false;
    border = 2;
    commands = [
      {
        command = "floating enable";
        criteria = {
          class = "File-roller";
        };
      }
      {
        command = "floating enable";
        criteria = {
          class = "org.gnome.Nautilus";
        };
      }
      {
        command = "floating enable";
        criteria = {
          class = "Gnome-screenshot";
        };
      }
    ];
  };

  gaps = {
    inner = 12;
    outer = 6;
    smartGaps = false;
    smartBorders = "on";
  };

  startup = [
    {
      command = "$HOME/.config/polybar/launch.sh";
      always = true;
      notification = false;
    }
    {
      command = "feh --bg-fill ~/.config/wallpaper.png";
      always = true;
      notification = false;
    }
    {
      command = "solaar -w hide &";
      always = true;
      notification = false;
    }
  #  { command = "exec firefox"; }
  #  { command = "exec steam"; }
  #  { command = "exec Discord"; }
  #] ++ lib.optionals isDesktop [
  #  { command = "xrand --output HDMI-0 --right-of DP-4"; notification = false; }
  #] ++ [
  #  # allow polybar to resize itself
  #  { command = "systemctl --user restart polybar"; always = true; notification = false; }
  ];

  #assigns = {
  #  "2: web" = [{ class = "^Firefox$"; }];
  #  "4" = [{ class = "^Steam$"; }];
  #  "6" = [{ class = "HexChat$"; }];
  #  "7" = [{ class = "^Discord$"; }];
  #};
  workspaceOutputAssign = [
    {
      output = "DP-2";
      workspace = "1";
    }
    {
      output = "DP-2";
      workspace = "2";
    }
    {
      output = "DP-2";
      workspace = "3";
    }
    {
      output = "DP-2";
      workspace = "4";
    }
    {
      output = "DP-2";
      workspace = "5";
    }
    {
      output = "DP-0";
      workspace = "10";
    }
  ];

  # colors
  colors = {
    focused          = { childBorder = "#cba6f7"; background = "#1e1e2e"; text = "#cdd6f4"; indicator = "#f9e2af"; border = "#cba6f7"; };
    focusedInactive  = { childBorder = "#1e1e2e"; background = "#1e1e2e"; text = "#cdd6f4"; indicator = "#1e1e2e"; border = "#1e1e2e"; };
    unfocused        = { childBorder = "#1e1e2e"; background = "#1e1e2e"; text = "#cdd6f4"; indicator = "#1e1e2e"; border = "#1e1e2e"; };
    urgent           = { childBorder = "#fab387"; background = "#1e1e2e"; text = "#fab387"; indicator = "#6c7086"; border = "#fab387"; };
    placeholder      = { childBorder = "#6c7086"; background = "#1e1e2e"; text = "#cdd6f4"; indicator = "#6c7086"; border = "#6c7086"; };
    background = "#1e1e2e";
  };

  keybindings = import ./keybindings.nix "Mod4";
}
