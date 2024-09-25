{
  # alacritty
  programs.alacritty = {
    enable = true;

    catppuccin.enable = true;

    settings = {
      window.padding = {
        x = 6;
        y = 6;
      };
      font = {
        size = 16;

        normal = {
          family = "Fira Code";
          style = "Regular";
        };
        bold = {
          family = "Fira Code";
          style = "Bold";
        };
        bold_italic = {
          family = "Fira Code";
          style = "Bold Italic";
        };
        italic = {
          family = "Fira Code";
          style = "Italic";
        };
      };
    };
  };
}
