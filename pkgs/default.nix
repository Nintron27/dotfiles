final: _prev: {
  spacetimedb = final.callPackage ./spacetimedb.nix { };
  # nixpkgs removed pkgs.brave; this overlay puts the upstream build back.
  brave = final.callPackage ./brave.nix { };
}
