mod:
{
  "${mod}+r" = "exec rofi -show drun";
  
  #"${mod}+w" = "exec firefox";
  #"${mod}+s" = "exec steam";
  #"${mod}+t" = "exec teams";
  #"${mod}+m" = "exec spotify";
  "${mod}+Return" = "exec alacritty";
  "${mod}+Shift+q" = "kill";
  #"${mod}+Alt+s" = "exec kill $(pgrep -f shutter); shutter -s";

  "XF86AudioRaiseVolume" = "exec amixer -q sset Master 10%+";
  "XF86AudioLowerVolume" = "exec amixer -q sset Master 10%-";
  "XF86AudioMute" = "exec amixer -q sset Master toggle";
  #"XF86AudioPlay" = "exec playerctl play";
  "XF86AudioPause" = "exec playerctl play-pause";
  "XF86AudioNext" = "exec playerctl next";
  "XF86AudioPrev" = "exec playerctl previous";

  #"${mod}+Shift+grave" = "move scratchpad";
  #"${mod}+grave" = "scratchpad show";

  "${mod}+n" = "focus left";
  "${mod}+e" = "focus down";
  "${mod}+i" = "focus up";
  "${mod}+o" = "focus right";

  "${mod}+Shift+n" = "move left";
  "${mod}+Shift+e" = "move down";
  "${mod}+Shift+i" = "move up";
  "${mod}+Shift+o" = "move right";

  "${mod}+h" = "split h";
  "${mod}+v" = "split v";
  "${mod}+f" = "fullscreen";
  #"${mod}+Shift+b" = "layout splith";
  #"${mod}+Shift+v" = "layout splitv";
  #"${mod}+Shift+s" = "layout stacking";
  #"${mod}+Shift+t" = "layout tabbed";
  "${mod}+Shift+f" = "floating toggle";
  #"${mod}+space" = "focus mode_toggle";

  "${mod}+Ctrl+n" = "resize shrink width 16px or 1ppt";
  "${mod}+Ctrl+e" = "resize grow height 16px or 1ppt";
  "${mod}+Ctrl+i" = "resize shrink height 16px or 1ppt";
  "${mod}+Ctrl+o" = "resize grow width 16px or 1ppt";

  "${mod}+1" = "workspace 1";
  "${mod}+2" = "workspace 2";
  "${mod}+3" = "workspace 3";
  "${mod}+4" = "workspace 4";
  "${mod}+5" = "workspace 5";
  "${mod}+6" = "workspace 6";
  "${mod}+7" = "workspace 7";
  "${mod}+8" = "workspace 8";
  "${mod}+9" = "workspace 9";
  "${mod}+0" = "workspace 10";
  "${mod}+Shift+1" = "move container to workspace 1";
  "${mod}+Shift+2" = "move container to workspace 2";
  "${mod}+Shift+3" = "move container to workspace 3";
  "${mod}+Shift+4" = "move container to workspace 4";
  "${mod}+Shift+5" = "move container to workspace 5";
  "${mod}+Shift+6" = "move container to workspace 6";
  "${mod}+Shift+7" = "move container to workspace 7";
  "${mod}+Shift+8" = "move container to workspace 8";
  "${mod}+Shift+9" = "move container to workspace 9";
  "${mod}+Shift+0" = "move container to workspace 10";
  
  "${mod}+Ctrl+l" = "exec i3lock -c b4befe";
  "${mod}+Ctrl+h" = "exec dm-tool switch-to-greeter";
  "${mod}+Ctrl+r" = "restart";
  "${mod}+Ctrl+x" = "exec \"i3-nagbar -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' -b 'Yes, exit i3' 'i3-msg exit'\"";
}
