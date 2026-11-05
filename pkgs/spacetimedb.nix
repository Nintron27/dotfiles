# Official v2.14.0 release.
# https://github.com/clockworklabs/SpacetimeDB/releases/tag/v2.14.0
# `spacetime start` execs `spacetimedb-standalone` from the CLI's directory.
{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "spacetimedb";
  version = "2.14.0";

  src = fetchurl {
    url = "https://github.com/clockworklabs/SpacetimeDB/releases/download/v${finalAttrs.version}/spacetime-x86_64-unknown-linux-gnu.tar.gz";
    hash = "sha256-LYlQ3DxnkQqoCqdhLv3bXubtU8RDVz9hezrWX+8qoIQ=";
  };

  # The archive contains the binaries at the top level.
  sourceRoot = ".";

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    zlib
    stdenv.cc.cc.lib
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 spacetimedb-cli $out/bin/spacetimedb-cli
    install -Dm755 spacetimedb-standalone $out/bin/spacetimedb-standalone
    ln -s spacetimedb-cli $out/bin/spacetime
    runHook postInstall
  '';

  meta = {
    description = "Relational database that runs application logic inside the database";
    homepage = "https://github.com/clockworklabs/SpacetimeDB";
    license = lib.licenses.bsl11;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "spacetime";
  };
})
