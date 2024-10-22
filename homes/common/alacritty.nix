{ config, ... }: {
  config = {
    programs.alacritty = {
      enable = true;

      catppuccin.enable = true;

      settings = {
        window.padding = {
          x = 6;
          y = 6;
        };
        font = {
          size = if config.isArgentum then 12 else 16;

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
  };
}
