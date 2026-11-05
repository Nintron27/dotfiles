# Updating Brave

This package downloads Brave's official `x86_64` `.deb` and wraps it. It does not compile Brave or Chromium. The wrapper also disables Brave's built-in updater, so version bumps happen here.

Both machines are `x86_64-linux`. Only that archive is listed in `pkgs/brave.nix`.

## Pick a release

Use a **Release** tag from https://github.com/brave/brave-browser/releases.

Skip tags whose title starts with Beta, Nightly, or Dev. The version in `pkgs/brave.nix` is the number without the leading `v` (`v1.99.54` becomes `1.99.54`).

## Bump the package

1. Set `version` in `pkgs/brave.nix`. The download URL is built from that version.
2. Replace `hash` with the new file's SRI hash:

```bash
VERSION=1.99.54
nix-prefetch-url --type sha256 \
  "https://github.com/brave/brave-browser/releases/download/v${VERSION}/brave-browser_${VERSION}_amd64.deb" \
  | xargs nix-hash --to-sri --type sha256
```

3. Rebuild:

```bash
sudo nixos-rebuild switch --flake .
```

`nix-prefetch-url` prints a base32 hash. The `nix-hash` step turns it into the `sha256-...` form that `fetchurl` expects. A wrong hash fails the download instead of installing a bad file.
