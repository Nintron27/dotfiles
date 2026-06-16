{ pkgs, inputs, ... }:
{
  config = {
    home.packages = [
      inputs.herdr.packages.${pkgs.system}.herdr
    ];
    home.file.".config/herdr/config.toml" = {
      source = ./config.toml;
    };
  };
}
