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
    kmonad = {
      url = "github:kmonad/kmonad?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nixos-hardware, catppuccin, home-manager, kmonad, ... }:
  {
    nixosConfigurations = {
      igneous = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        specialArgs = { 
          inherit inputs;
        };

        modules = [
          ./hosts/igneous
        ];
      };
      argentum = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        specialArgs = { 
          inherit inputs;
        };

        modules = [
          ./hosts/argentum
          nixos-hardware.nixosModules.framework-13-7040-amd
          kmonad.nixosModules.default
        ];
      };
    };
  };
}
