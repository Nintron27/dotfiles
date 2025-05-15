{ inputs, lib, ... }: {
  programs.helix = {
    enable = true;
    package = inputs.helix.packages."x86_64-linux".default;
    # catppuccin.enable = true; # Done below instead
  };
  home.file.".config/helix" = {
    source = ./config;
  };

  # Binary cache for Helix unstable
  nix.settings =
  {
    substituters = lib.singleton "https://helix.cachix.org";
    trusted-public-keys = lib.singleton "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs=";
  };
}
