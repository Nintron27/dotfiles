{ inputs, ... }: {
  programs.helix = {
    enable = true;
    package = inputs.helix.packages."x86_64-linux".default;
    # catppuccin.enable = true; # Done below instead
  };
  home.file.".config/helix" = {
    source = ./config;
  };
}
