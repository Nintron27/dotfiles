# Jailed LLM agents for home-manager.
#
# Project specific toolchains should not be listed in extraPkgs.
# At agent start try-fwd-dev-shell evaluates the nearest
# flake's dev shell and injects only that shell's store closure.
{ lib, pkgs, inputs, ... }:

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

  agentJailOptions = jailed.commonJailOptions
    ++ herdrJailOptions
    ++ [ try-fwd-dev-shell ];
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
      ];
      baseJailOptions = agentJailOptions;
    })

    (jailed.makeJailedOpencode {
      name = "opencode";
      baseJailOptions = agentJailOptions;
    })
  ];
}
