# Home Manager config shared by every user. Terminal setup (./cli) goes
# everywhere; the graphical setup (./desktop) is skipped on headless hosts (arx).
{ pkgs, lib, username, inputs, headless ? false, ... }:

{
  imports = [ ./cli ] ++ lib.optional (!headless) ./desktop;

  options.isArgentum = lib.mkOption {
    default = false;
    type = lib.types.bool;
    description = ''
      Enable all package/feature related settings to Argentum
    '';
  };

  config = {
    home.stateVersion = "23.11";

    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.allowBroken= true;
    nixpkgs.overlays = [
      inputs.grok-bot.overlays.default
      (import ../../pkgs)
    ];
    # Allow EOL
    nixpkgs.config.permittedInsecurePackages = [
      "beekeeper-studio-5.3.4"
    ];

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;

    home.username = username;
    home.homeDirectory = "/home/${username}";
  };
}
