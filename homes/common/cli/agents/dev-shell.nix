# Run a jailed agent inside the project's dev shell.
#
# Inside the jail the agent is started as
#
#     nix develop .#agent --command <agent> "$@"
#
# so it gets exactly the shell you get from `nix develop .#agent`: every
# package, the stdenv, the shellHook and the variables it sets. Evaluation,
# the shellHook and the agent all run inside the jail.
#
# Requires the agent to be built with `enableNix = true` (jailed-agents),
# which mounts /nix read-only, the Nix daemon socket and /etc/nix/nix.conf.
#
# Choosing the shell (JAIL_DEV_SHELL is forwarded into the jail):
#   unset                      ./flake.nix's devShells.<system>.agent if it
#                              exists, otherwise no dev shell
#   JAIL_DEV_SHELL=.#default   any installable `nix develop` accepts
#   JAIL_DEV_SHELL=0           no dev shell
#
# Only the current directory is mounted, so start the agent from the flake's
# root directory.
#
# Your ~/.cache/nix is visible through a throwaway overlay, so a shell you
# already evaluated on the host (e.g. `nix develop .#agent`, same commit)
# starts without re-evaluating, and the jail can't alter your host's cache.
#
# Safety: the jail talks to the Nix daemon as you. A trusted Nix user
# (nix.settings.trusted-users) is root-equivalent, so the jail refuses to
# start if the daemon reports you as trusted.
{ pkgs, combinators }:

let
  inherit (combinators)
    compose
    add-runtime
    try-fwd-env
    try-ro-bind
    wrap-entry
    ;

  nix = "${pkgs.nix}/bin/nix";
  jq = "${pkgs.jq}/bin/jq";
  system = pkgs.stdenv.hostPlatform.system;
in
compose [
  # Host side, before bwrap starts.
  (add-runtime ''
    jail_nix_trusted=$(${nix} --extra-experimental-features nix-command \
      store info --store daemon --json 2>/dev/null | ${jq} -r .trusted) \
      || jail_nix_trusted=unknown
    if [ "$jail_nix_trusted" != false ]; then
      echo "jail: refusing to start: the Nix daemon reports trusted=$jail_nix_trusted for $(id -un)." >&2
      echo "jail: a trusted Nix user is root-equivalent and the jail can reach the daemon." >&2
      echo "jail: remove $(id -un) from nix.settings.trusted-users (check with: nix store info)." >&2
      exit 1
    fi

    # Reuse your Nix caches (evaluation, fetchers) without letting the jail
    # change them: it sees ~/.cache/nix through an overlay whose writes are
    # thrown away when the jail exits.
    if [ -d "$HOME/.cache/nix" ]; then
      RUNTIME_ARGS+=(--overlay-src "$HOME/.cache/nix" --tmp-overlay "$HOME/.cache/nix")
    fi
  '')

  # Pinned flake registry, so `nix shell nixpkgs#foo` uses the system's nixpkgs.
  (try-ro-bind "/etc/nix/registry.json" "/etc/nix/registry.json")

  (try-fwd-env "JAIL_DEV_SHELL")

  # Inside the jail.
  (wrap-entry (entry: ''
    dev_shell=''${JAIL_DEV_SHELL-}

    if [ -z "$dev_shell" ] && [ -f flake.nix ]; then
      has_agent=$(${nix} eval --raw '.#devShells.${system}' \
        --apply 's: if s ? agent then "yes" else "no"' 2>/dev/null) \
        || has_agent=error
      case "$has_agent" in
        yes) dev_shell=.#agent ;;
        no) echo "jail: flake.nix has no devShells.${system}.agent; starting without a dev shell" >&2 ;;
        *) echo "jail: could not evaluate devShells.${system} in flake.nix (try: nix eval .#devShells.${system}); starting without a dev shell" >&2 ;;
      esac
    fi

    if [ -n "$dev_shell" ] && [ "$dev_shell" != 0 ]; then
      echo "jail: entering dev shell $dev_shell" >&2
      exec ${nix} develop "$dev_shell" --command ${entry}
    fi
    exec ${entry}
  ''))
]
