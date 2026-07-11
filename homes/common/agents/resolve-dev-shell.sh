# Resolve a flake devShells.agent toolchain for jail injection.
#
# Usage: resolve-dev-shell <out-env-file> <out-binds-file> [agent-argv...]
#
# Soft-fails (exit 0, empty outputs) when disabled / no flake / no agent shell /
# nix missing / eval error.
#
# Toolchain mode (not a full `nix develop` session):
#   - Reads the shell derivation via `nix derivation show` (attrs the user
#     put on mkShell), NOT `nix print-dev-env` (full stdenv runtime dump).
#   - Packages: buildInputs + nativeBuildInputs (+ propagated), runtime closures.
#   - PATH: <pkg>/bin for those packages only (no gcc/stdenv stack).
#   - Env: non-reserved derivation env strings (FOO, BAR, env.FOO, …).
#   - shellHook is NOT executed (and is treated as reserved / not exported).
#
# out-env-file:   bash snippet sourced inside the jail (PATH + env)
# out-binds-file: NUL-separated bwrap args: --ro-bind <path> <path> ...
#                 (same technique as jail.nix bind-nix-store-runtime-closure)
#
# Defaults / overrides:
#   (none)                     nearest flake's #devShells.<system>.agent
#   JAIL_DEV_SHELL=0           disable injection entirely
#   JAIL_DEV_SHELL=<installable>  use this installable (e.g. .#default)
#   JAIL_FLAKE_ROOT=/path      directory containing flake.nix
#   JAIL_DEV_SHELL_MAX_DEPTH=N stop after N parent hops (default: unlimited)
#   JAIL_DEV_SHELL_DEBUG=1     log resolve decisions to stderr
#
# Flake discovery starts from the first existing directory (or parent of file)
# among agent-argv, else $PWD — so `grok /path/to/project` works without cd.

set -euo pipefail

out_env="${1:?usage: resolve-dev-shell <out-env> <out-binds> [argv...]}"
out_binds="${2:?usage: resolve-dev-shell <out-env> <out-binds> [argv...]}"
shift 2

: >"$out_env"
: >"$out_binds"

debug() {
  if [ "${JAIL_DEV_SHELL_DEBUG-}" = "1" ]; then
    echo "jail-dev-shell: $*" >&2
  fi
}

# --- opt out -------------------------------------------------------------------
case "${JAIL_DEV_SHELL-}" in
  0)
    debug "disabled (JAIL_DEV_SHELL=0)"
    exit 0
    ;;
esac

if ! command -v nix >/dev/null 2>&1; then
  debug "nix not on PATH; skipping"
  exit 0
fi

# --- start directory (argv project path, else PWD) -----------------------------
start_dir="$PWD"
for arg in "$@"; do
  case "$arg" in
    -*) continue ;;
  esac
  if [ -d "$arg" ]; then
    start_dir="$(cd -- "$arg" && pwd)"
    debug "using directory arg as start: $start_dir"
    break
  fi
  if [ -f "$arg" ]; then
    start_dir="$(cd -- "$(dirname -- "$arg")" && pwd)"
    debug "using file arg parent as start: $start_dir"
    break
  fi
done

# --- find installable ----------------------------------------------------------
installable="${JAIL_DEV_SHELL-}"

if [ -z "$installable" ]; then
  if [ -n "${JAIL_FLAKE_ROOT-}" ]; then
    if [ ! -f "$JAIL_FLAKE_ROOT/flake.nix" ]; then
      debug "JAIL_FLAKE_ROOT has no flake.nix: $JAIL_FLAKE_ROOT"
      exit 0
    fi
    flake_root="$JAIL_FLAKE_ROOT"
  else
    d="$start_dir"
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
    if [ -z "$flake_root" ]; then
      debug "no flake.nix above $start_dir"
      exit 0
    fi
  fi

  system=$(nix eval --impure --raw --expr 'builtins.currentSystem' 2>/dev/null) || {
    debug "could not determine builtins.currentSystem"
    exit 0
  }
  installable="${flake_root}#devShells.${system}.agent"
  debug "flake root: $flake_root"
fi

debug "installable: $installable"

# --- evaluate agent shell (derivation attrs, not print-dev-env) -----------------
# `nix derivation show` exposes what was declared on the mkShell/mkDerivation
# (packages + user FOO=… / env.FOO=…). It does NOT run stdenv setup hooks, so we
# never see HOME=/homeless-shelter, full compiler PATH, NIX_CFLAGS, etc.
#
# Reserved keys below are the fixed mkDerivation/mkShell schema — not an open-
# ended stdenv deny list. Everything else string-valued is treated as user env.
json=$(mktemp)
pkg_roots=$(mktemp)
bind_roots=$(mktemp)
closure_file=$(mktemp)
tmp_env=$(mktemp)
tmp_binds=$(mktemp)
trap 'rm -f "$json" "$pkg_roots" "$bind_roots" "$closure_file" "$tmp_env" "$tmp_binds"' EXIT

if ! nix derivation show "$installable" >"$json" 2>/dev/null; then
  debug "derivation show failed for $installable"
  exit 0
fi

# Package roots for PATH (mkShell `packages` → nativeBuildInputs).
# Closure roots also include store paths from user env values (e.g. FOO = "${pkgs.x}").
jq -r -f /dev/stdin "$json" >"$pkg_roots" <<'JQ'
def store_paths:
  [scan("/nix/store/[a-z0-9]{32}-[A-Za-z0-9+._?-]+")];

(.derivations | to_entries[0].value.env // {}) as $env
| [
    ($env.buildInputs // ""),
    ($env.nativeBuildInputs // ""),
    ($env.propagatedBuildInputs // ""),
    ($env.propagatedNativeBuildInputs // "")
  ]
| join(" ")
| store_paths
| unique[]
JQ

cp "$pkg_roots" "$bind_roots"

jq -r -f /dev/stdin "$json" >>"$bind_roots" <<'JQ'
def store_paths:
  [scan("/nix/store/[a-z0-9]{32}-[A-Za-z0-9+._?-]+")];

def reserved:
  [
    "name", "builder", "system", "out", "outputs", "stdenv",
    "shellHook",
    "buildInputs", "nativeBuildInputs",
    "propagatedBuildInputs", "propagatedNativeBuildInputs",
    "depsBuildBuild", "depsBuildBuildPropagated",
    "depsBuildTarget", "depsBuildTargetPropagated",
    "depsHostHost", "depsHostHostPropagated",
    "depsTargetTarget", "depsTargetTargetPropagated",
    "buildPhase", "phases", "preferLocalBuild", "strictDeps",
    "cmakeFlags", "configureFlags", "mesonFlags", "patches",
    "doCheck", "doInstallCheck",
    "__structuredAttrs", "__ignoreNulls"
  ];

.derivations | to_entries[0].value.env // {}
| to_entries[]
| select(.key as $k | reserved | index($k) | not)
| select(.value | type == "string")
| .value
| store_paths[]
JQ

sort -u -o "$bind_roots" "$bind_roots"

if [ ! -s "$pkg_roots" ] && [ ! -s "$bind_roots" ]; then
  debug "no package or env store roots in shell derivation; skipping"
  exit 0
fi

# Runtime closure so ELF RPATHs resolve — not the entire store.
# xargs batches so nix-store never hits ARG_MAX.
xargs -a "$bind_roots" -d '\n' -r nix-store --query --requisites \
  | sort -u >"$closure_file"

if [ ! -s "$closure_file" ]; then
  debug "empty runtime closure; skipping"
  exit 0
fi

# PATH: <pkg>/bin for declared packages only (thin toolchain).
filtered_path=""
while IFS= read -r root; do
  [ -d "$root/bin" ] || continue
  if [ -n "$filtered_path" ]; then
    filtered_path="${filtered_path}:${root}/bin"
  else
    filtered_path="${root}/bin"
  fi
done <"$pkg_roots"

if [ -z "$filtered_path" ]; then
  debug "package roots have no bin/ dirs; skipping"
  exit 0
fi

debug "packages: $(wc -l <"$pkg_roots") path roots, $(wc -l <"$bind_roots") bind roots, $(wc -l <"$closure_file") closure paths"

# --- env snippet (user derivation attrs only) ----------------------------------
jq -r -f /dev/stdin --arg path "$filtered_path" "$json" >"$tmp_env" <<'JQ'
def reserved:
  [
    "name", "builder", "system", "out", "outputs", "stdenv",
    "shellHook",
    "buildInputs", "nativeBuildInputs",
    "propagatedBuildInputs", "propagatedNativeBuildInputs",
    "depsBuildBuild", "depsBuildBuildPropagated",
    "depsBuildTarget", "depsBuildTargetPropagated",
    "depsHostHost", "depsHostHostPropagated",
    "depsTargetTarget", "depsTargetTargetPropagated",
    "buildPhase", "phases", "preferLocalBuild", "strictDeps",
    "cmakeFlags", "configureFlags", "mesonFlags", "patches",
    "doCheck", "doInstallCheck",
    "__structuredAttrs", "__ignoreNulls"
  ];

"JAIL_DEV_SHELL_PATH=\($path|@sh)",
(
  .derivations | to_entries[0].value.env // {}
  | to_entries[]
  | select(.key as $k | reserved | index($k) | not)
  | select(.value | type == "string")
  | "export \(.key)=\(.value|@sh)"
),
"export IN_NIX_SHELL=impure"
JQ

# --- selective store binds (package + user-env store paths, full closure) ------
# Why not RUNTIME_ARGS+=(--ro-bind ...) in a loop?
#   Large closures can exceed ARG_MAX when exec'ing bwrap. jail.nix avoids
#   that with bwrap --args <fd> reading NUL-separated tokens from a file
#   (see bind-nix-store-runtime-closure). We do the same here.

while IFS= read -r p; do
  [ -e "$p" ] || continue
  printf '%s\0' --ro-bind "$p" "$p"
done <"$closure_file" >"$tmp_binds"

if [ ! -s "$tmp_binds" ]; then
  debug "no bindable store paths; skipping"
  exit 0
fi

# Commit outputs only when both env and binds are ready.
cp "$tmp_env" "$out_env"
cp "$tmp_binds" "$out_binds"

debug "injected PATH=$filtered_path"
debug "wrote env $(wc -c <"$out_env") bytes, binds $(wc -c <"$out_binds") bytes"
