{
  catppuccin.dunst.enable = true;
  services.dunst = {
    enable = true;
    # configFile = ./config/dunst/dunstrc;
    settings = {
      global = {
        monitor = 0;
        geometry = "0x0-20+35";
        indicate_hidden = "yes";
        shrink = "no";
        separator_height = 2;
        padding = 6;
        horizontal_padding = 6;
        corner_radius = 6;
        frame_width = 2;
        sort = "yes";
        idle_threshold = 120;

        font = "Fira Code 12";

        show_age_threshold = 60;

        max_icon_size = 56;
        icon_corner_radius = 6;
      };
    };
  };
}
