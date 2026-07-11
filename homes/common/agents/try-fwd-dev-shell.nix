# Custom jail.nix combinator: inject the nearest flake's devShells.agent
# toolchain into the jail at agent start.
#
# Built the same way as complex upstream combinators (compose + add-runtime +
# wrap-entry). See jail.nix:
#   - bind-nix-store-runtime-closure  (NUL --args fd for large bind lists)
#   - readonly-paths-from-var         (runtime path discovery via add-runtime)
#   - add-pkg-deps                    (PATH + runtime closure bookkeeping)
#
# Default: nearest flake's #devShells.<system>.agent (see resolve-dev-shell.sh).
# Soft-fail: no agent shell / nix / eval error → agent starts with base extraPkgs only.
# shellHook is never run. User env comes from `nix derivation show` (declared
# mkShell attrs), not from print-dev-env's stdenv dump.
#
# Usage:
#   cd ~/project && grok
#   grok /path/to/project              # no need to cd first
#   JAIL_DEV_SHELL=.#default grok     # use human dev shell instead of .agent
#   JAIL_DEV_SHELL=0 grok             # disable injection
#   JAIL_FLAKE_ROOT=/path/to/flake grok
#   JAIL_DEV_SHELL_MAX_DEPTH=5 grok
#   JAIL_DEV_SHELL_DEBUG=1 grok       # stderr resolve logs

{ pkgs, combinators }:

let
  inherit (combinators)
    compose
    add-runtime
    add-cleanup
    wrap-entry
    ;

  resolveDevShell = pkgs.writeShellApplication {
    name = "jail-resolve-dev-shell";
    runtimeInputs = [
      pkgs.nix # host daemon client; do not rely on parent PATH
      pkgs.jq
      pkgs.coreutils
      pkgs.findutils # xargs
    ];
    text = builtins.readFile ./resolve-dev-shell.sh;
  };
in
compose [
  (add-runtime ''
    JAIL_DEV_SHELL_ENV_HOST=$(mktemp)
    JAIL_DEV_SHELL_BINDS_HOST=$(mktemp)

    # Pass agent argv so resolve can honor `grok /path/to/project` without cd.
    if ${resolveDevShell}/bin/jail-resolve-dev-shell \
         "$JAIL_DEV_SHELL_ENV_HOST" "$JAIL_DEV_SHELL_BINDS_HOST" \
         "$@" \
       && [ -s "$JAIL_DEV_SHELL_ENV_HOST" ]; then
      RUNTIME_ARGS+=(--ro-bind "$JAIL_DEV_SHELL_ENV_HOST" /run/jail-dev-shell.env)
      RUNTIME_ARGS+=(--setenv JAIL_DEV_SHELL_ENV /run/jail-dev-shell.env)

      # Selective store binds via bwrap --args <fd> (avoids ARG_MAX).
      if [ -s "$JAIL_DEV_SHELL_BINDS_HOST" ]; then
        exec {JAIL_DEV_SHELL_BINDS_FD}<"$JAIL_DEV_SHELL_BINDS_HOST"
        RUNTIME_ARGS+=(--args "$JAIL_DEV_SHELL_BINDS_FD")
      fi
    else
      rm -f "$JAIL_DEV_SHELL_ENV_HOST" "$JAIL_DEV_SHELL_BINDS_HOST"
      unset JAIL_DEV_SHELL_ENV_HOST JAIL_DEV_SHELL_BINDS_HOST
    fi
  '')

  (add-cleanup ''
    if [ -n "''${JAIL_DEV_SHELL_ENV_HOST-}" ]; then
      rm -f "$JAIL_DEV_SHELL_ENV_HOST"
    fi
    if [ -n "''${JAIL_DEV_SHELL_BINDS_HOST-}" ]; then
      rm -f "$JAIL_DEV_SHELL_BINDS_HOST"
    fi
  '')

  (wrap-entry (entry: ''
    if [ -n "''${JAIL_DEV_SHELL_ENV-}" ] && [ -f "$JAIL_DEV_SHELL_ENV" ]; then
      # shellcheck disable=SC1090
      . "$JAIL_DEV_SHELL_ENV"
      if [ -n "''${JAIL_DEV_SHELL_PATH-}" ]; then
        export PATH="$JAIL_DEV_SHELL_PATH:$PATH"
      fi
    fi
    ${entry}
  ''))
]
