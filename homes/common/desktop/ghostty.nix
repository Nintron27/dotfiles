{ config, ... }: {
  config = {
    catppuccin.ghostty.enable = true;
    programs.ghostty = {
      enable = true;
      enableFishIntegration = true;

      systemd.enable = true;

      settings = {
          quit-after-last-window-closed = true;
          quit-after-last-window-closed-delay = "5m";

          font-size = if config.isArgentum then 12 else 16;
          font-family = "Liberation Mono";
          font-feature = ["-calt" "-liga" "-dlig"];

          cursor-style = "block";
          cursor-style-blink = true;
          shell-integration-features = "no-cursor";

          window-padding-x = 4;
          window-padding-y = 4;
      };
    };
  };
}
