# Official stable Brave, wrapped the same way nixpkgs did before it was
# removed. Nixpkgs dropped the package because no committer remained to
# merge security updates (NixOS/nixpkgs#582838), not because upstream stopped
# shipping builds.
#
# Bump steps: pkgs/brave/UPDATE.md
{
  callPackage,
}:

let
  release = rec {
    pname = "brave";
    version = "1.99.54";

    archives = {
      x86_64-linux = {
        url = "https://github.com/brave/brave-browser/releases/download/v${version}/brave-browser_${version}_amd64.deb";
        hash = "sha256-uEskEvFEVN81uX4yLTR7h2vQshnfcv1ha20F+4UB82o=";
      };
    };

    optStem = "brave";
    fileStem = "brave-browser";
    appIdStem = "com.brave.Browser";
    darwinStem = "Brave Browser";
    changelogFile = "CHANGELOG_DESKTOP.md";
    homepage = "https://brave.com/";
    innerBinary = "brave";
  };
in
callPackage ((import ./brave/make-brave.nix) release) { }
