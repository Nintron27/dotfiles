# Resolve a flake dev shell for jail injection.
#
# Usage: resolve-dev-shell <out-env-file> <out-binds-file>
#
# Soft-fails (exit 0, empty outputs) when there is no flake / nix / eval error.
#
# out-env-file:   bash snippet sourced inside the jail (PATH + toolchain env)
# out-binds-file: NUL-separated bwrap args: --ro-bind <path> <path> ...
#                 (same technique as jail.nix bind-nix-store-runtime-closure)

set -euo pipefail

out_env="${1:?usage: resolve-dev-shell <out-env> <out-binds>}"
out_binds="${2:?usage: resolve-dev-shell <out-env> <out-binds>}"
: >"$out_env"
: >"$out_binds"

if ! command -v nix >/dev/null 2>&1; then
  exit 0
fi

# --- find installable ----------------------------------------------------------
# Walk upward from $PWD looking for flake.nix.
# Continues until filesystem root "/" (does not check "/" itself for flake.nix).
# Override with:
#   JAIL_DEV_SHELL=.#myShell   explicit flake installable
#   JAIL_FLAKE_ROOT=/path      directory containing flake.nix
#   JAIL_DEV_SHELL_MAX_DEPTH=N stop after N parent hops (default: unlimited)

installable="${JAIL_DEV_SHELL-}"

if [ -z "$installable" ]; then
  if [ -n "${JAIL_FLAKE_ROOT-}" ]; then
    [ -f "$JAIL_FLAKE_ROOT/flake.nix" ] || exit 0
    installable="$JAIL_FLAKE_ROOT"
  else
    d="$PWD"
    depth=0
    max_depth="${JAIL_DEV_SHELL_MAX_DEPTH-}"
    flake_root=""
    while [ -n "$d" ] && [ "$d" != "/" ]; do
      if [ -f "$d/flake.nix" ]; then
        flake_root="$d"
        break
      fi
      depth=$((depth + 1))
      if [ -n "$max_depth" ] && [ "$depth" -ge "$max_depth" ]; then
        break
      fi
      d=$(dirname "$d")
    done
    [ -n "$flake_root" ] || exit 0
    installable="$flake_root"
  fi
fi

# --- evaluate dev shell (same data as `nix develop`) ---------------------------
json=$(mktemp)
roots=$(mktemp)
trap 'rm -f "$json" "$roots"' EXIT

if ! nix print-dev-env --json "$installable" >"$json" 2>/dev/null; then
  case "$installable" in
    *\#*) exit 0 ;;
  esac
  system=$(nix eval --impure --raw --expr 'builtins.currentSystem' 2>/dev/null) || exit 0
  nix print-dev-env --json "${installable}#devShells.${system}.default" >"$json" 2>/dev/null || exit 0
fi

dev_path=$(jq -r '.variables.PATH.value // empty' "$json")
[ -n "$dev_path" ] || exit 0

# --- env file: PATH + store-linked toolchain vars ------------------------------
# Skip host/build-only keys. @sh produces safe shell quoting (replaces python).
jq -r '
  def denied:
    . as $k
    | [
        "HOME","USER","LOGNAME","SHELL","CONFIG_SHELL","shell",
        "TMP","TEMP","TMPDIR","TEMPDIR","PWD","OLDPWD","SHLVL","_",
        "NIX_BUILD_TOP","NIX_LOG_FD","NIX_BUILD_CORES",
        "builder","out","outputs","outputName","stdenv","name","system","PATH"
      ]
    | index($k) != null;

  (.variables.PATH.value // empty) as $path
  | "JAIL_DEV_SHELL_PATH=\($path|@sh)",
    (
      .variables
      | to_entries[]
      | select(.value.type == "exported")
      | select(.value.value | type == "string")
      | select(.key | denied | not)
      | select(.value.value | contains("/nix/store"))
      | select(.value.value | startswith("/build") | not)
      | "export \(.key)=\(.value.value|@sh)"
    ),
    "export IN_NIX_SHELL=impure"
' "$json" >"$out_env"

# --- selective store binds -----------------------------------------------------
# Every /nix/store path referenced by the shell env, expanded to its full
# runtime closure (so ELF RPATHs resolve) — not the entire store.
#
# Why not RUNTIME_ARGS+=(--ro-bind ...) in a loop?
#   Large closures can exceed ARG_MAX when exec'ing bwrap. jail.nix avoids
#   that with bwrap --args <fd> reading NUL-separated tokens from a file
#   (see bind-nix-store-runtime-closure). We do the same here.

jq -r '
  .variables
  | to_entries[]
  | select(.value.type == "exported" and (.value.value | type == "string"))
  | .value.value
' "$json" \
  | grep -oE '/nix/store/[a-z0-9]{32}-[^/[:space:]:'\''"]+' \
  | sort -u >"$roots"

[ -s "$roots" ] || exit 0

# xargs batches automatically so nix-store itself never hits ARG_MAX.
mapfile -t closure < <(
  xargs -a "$roots" -d '\n' -r nix-store --query --requisites | sort -u
)

for p in "${closure[@]}"; do
  # Skip missing paths (defensive; nix-store output should exist on a normal host).
  [ -e "$p" ] || continue
  printf '%s\0' --ro-bind "$p" "$p"
done >"$out_binds"
