# Jailed LLM agents for home-manager.
#
# Project toolchains should NOT listed in extraPkgs.
# At agent start try-fwd-dev-shell looks for the nearest flake's
# devShells.<system>.agent and injects that shell's packages
# (plus runtime closures) into the jail.
#
# Convention (like README.md vs AGENTS.md):
#   devShells.default  — human interactive shell (`nix develop`, direnv)
#   devShells.agent    — tools for jailed agents (LSP, formatters, CLIs)
#
# If there is no flake or no `devShells.agent`, the agent still starts with
# base packages + any extraPkgs only. shellHook is never run.
# User env attrs on the shell (FOO = "…", or env.FOO) are forwarded; the
# injector reads the derivation (`nix derivation show`), not print-dev-env.
#
# Overrides (see resolve-dev-shell.sh):
#   JAIL_DEV_SHELL=0           disable
#   JAIL_DEV_SHELL=.#default   use human shell instead
#   JAIL_DEV_SHELL_DEBUG=1     resolve logs on stderr
{
  lib,
  pkgs,
  inputs,
  ...
}:

let
  jailed = inputs.jailed-agents.lib.${pkgs.system};
  combinators = jailed.internals.jail.combinators;

  try-fwd-dev-shell = import ./try-fwd-dev-shell.nix {
    inherit pkgs combinators;
  };

  # Optional herdr + terminal plumbing shared by all agents.
  herdrJailOptions = [
    (combinators.add-runtime ''
      if [ -n "''${HERDR_SOCKET_PATH:-}" ]; then
        socket_dir=$(dirname "''${HERDR_SOCKET_PATH}")
        if [ -d "$socket_dir" ]; then
          RUNTIME_ARGS+=(--bind "$socket_dir" "$socket_dir")
        fi
      fi
    '')
    (combinators.try-fwd-env "HERDR_ENV")
    (combinators.try-fwd-env "HERDR_SOCKET_PATH")
    (combinators.try-fwd-env "HERDR_PANE_ID")

    # base only forwards TERM; agents need full color capability detection
    (combinators.try-fwd-env "TERM")
    (combinators.try-fwd-env "COLORTERM")
    (combinators.try-fwd-env "TERM_PROGRAM")

    (combinators.readonly-paths-from-var "JAIL_READ" ":")
  ];

  agentJailOptions = jailed.commonJailOptions ++ herdrJailOptions ++ [ try-fwd-dev-shell ];
in
{
  home.packages = [
    (jailed.makeJailedPi {
      name = "pi";
      extraPkgs = [ ];
      baseJailOptions = agentJailOptions ++ [
        (combinators.try-fwd-env "HERDR_PI_IDLE_DEBOUNCE_MS")
        (combinators.try-fwd-env "HERDR_PI_RETRY_GRACE_MS")
      ];
    })

    # Grok Build via llm-agents.nix; no makeJailedGrok yet.
    (jailed.makeJailedAgent {
      name = "grok";
      pkg = inputs.llm-agents.packages.${pkgs.system}.grok;
      configPaths = [ "~/.grok" ];
      extraPkgs = with pkgs; [
        patch
        zip
        xz
        nix
        nixfmt
        python3
      ];
      baseJailOptions = agentJailOptions;
    })

    (jailed.makeJailedOpencode {
      name = "opencode";
      baseJailOptions = agentJailOptions;
    })
  ];
}
