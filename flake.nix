{
  description = "My NixOS config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    catppuccin.url = "github:catppuccin/nix";
    # hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1&ref=refs/tags/v0.41.2";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    kmonad = {
      url = "github:kmonad/kmonad?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Unofficial packaging of the official Grok Bot AppImage.
    # https://github.com/aijorgenson/grokbot-nixos
    grok-bot = {
      url = "github:aijorgenson/grokbot-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";
    jail-nix.url = "sourcehut:~alexdavid/jail.nix";
    llm-agents.url = "github:numtide/llm-agents.nix";

    jailed-agents = {
      url = "github:andersonjoseph/jailed-agents";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.jail-nix.follows = "jail-nix";
      inputs.llm-agents.follows = "llm-agents";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = inputs@{ self, nixpkgs, nixos-hardware, catppuccin, home-manager, kmonad, ... }:
  let
    settings = import ./settings.nix;
  in
  {
    nixosConfigurations = {
      igneous = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        specialArgs = {
          inherit inputs settings;
        };

        modules = [
          ./hosts/igneous
        ];
      };
      argentum = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        specialArgs = {
          inherit inputs settings;
        };

        modules = [
          ./hosts/argentum
          nixos-hardware.nixosModules.framework-13-7040-amd
          kmonad.nixosModules.default
        ];
      };
      arx = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        specialArgs = {
          inherit inputs settings;
        };

        modules = [
          ./hosts/arx
          inputs.disko.nixosModules.disko
          inputs.sops-nix.nixosModules.sops
        ];
      };
    };
  };
}
