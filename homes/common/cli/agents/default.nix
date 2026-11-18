# Jailed LLM agents for home-manager.
#
# Project toolchains should NOT be listed in extraPkgs. Each agent starts
# inside the dev shell of the flake in the current directory
# instead (see dev-shell.nix):
#
#   devShells.default  — human interactive shell (`nix develop`, direnv)
#   devShells.agent    — what agents get; usually
#                        mkShell { inputsFrom = [ default ]; packages = [ … ]; }
#
# Inside the jail the agent runs as `nix develop .#agent --command <agent>`,
# so it sees exactly the shell you would. No agent shell: base packages only.
#
# Overrides:
#   JAIL_DEV_SHELL=.#default   use another shell
#   JAIL_DEV_SHELL=0           no dev shell
#   JAIL_READ=/a:/b            extra read-only paths
{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:

let
  jailed = inputs.jailed-agents.lib.${pkgs.stdenv.hostPlatform.system};
  combinators = jailed.internals.jail.combinators;

  devShell = import ./dev-shell.nix {
    inherit pkgs combinators;
  };

  # Terminal plumbing shared by all agents.
  terminalJailOptions = [
    # base only forwards TERM; agents need full color capability detection
    (combinators.try-fwd-env "TERM")
    (combinators.try-fwd-env "COLORTERM")
    (combinators.try-fwd-env "TERM_PROGRAM")

    (combinators.readonly-paths-from-var "JAIL_READ" ":")
  ];

  # Every agent here must also set `enableNix = true;` (dev-shell.nix needs the
  # Nix daemon and /nix inside the jail).
  agentJailOptions = jailed.commonJailOptions ++ terminalJailOptions ++ [ devShell ];

  # Commit as the user, SSH-sign commits, and fetch/push over SSH using the
  # dedicated ssh-agent-jail key below. See git-ssh.nix for one-time setup.
  gitSshJailOptions = import ./git-ssh.nix {
    inherit pkgs combinators;
    userName = "Nintron";
    userEmail = "nintron@sent.com";
  };

  # Holds only ~/.ssh/jail_ed25519 (auto-loaded, no passphrase). Separate from
  # the host's normal agent (programs.ssh.startAgent) so the jail can't use
  # any other key.
  loadJailKey = pkgs.writeShellApplication {
    name = "ssh-agent-jail-load-key";
    runtimeInputs = [
      pkgs.openssh
      pkgs.coreutils
    ];
    text = ''
      sock=$1
      key=$2
      for _ in $(seq 50); do
        [ -S "$sock" ] && break
        sleep 0.1
      done
      if [ -f "$key" ]; then
        SSH_AUTH_SOCK="$sock" ssh-add "$key" </dev/null
      else
        echo "ssh-agent-jail: $key not found; agent left empty" >&2
      fi
    '';
  };
in
{
  systemd.user.services.ssh-agent-jail = lib.mkIf config.packageConfiguration.enableWork {
    Unit.Description = "SSH agent for jailed coding agents (only ~/.ssh/jail_ed25519)";
    Service = {
      ExecStartPre = "${pkgs.coreutils}/bin/rm -f %t/ssh-agent-jail";
      ExecStart = "${pkgs.openssh}/bin/ssh-agent -D -a %t/ssh-agent-jail";
      # "-": a missing or passphrase-protected key must not fail the agent.
      ExecStartPost = "-${loadJailKey}/bin/ssh-agent-jail-load-key %t/ssh-agent-jail %h/.ssh/jail_ed25519";
    };
    Install.WantedBy = [ "default.target" ];
  };

  home.packages = [
    # Grok Build via llm-agents.nix; no makeJailedGrok yet.
    (jailed.makeJailedAgent {
      name = "grok";
      enableNix = true;
      pkg = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.grok;
      configPaths = [ "~/.grok" ];
      extraPkgs = with pkgs; [
        github-cli
        patch
        zip
        xz
        nixfmt
        python3
      ];
      baseJailOptions = agentJailOptions;
    })

    (jailed.makeJailedClaudeCode {
      name = "claude";
      enableNix = true;
      extraPkgs = with pkgs; [
        github-cli
        patch
        zip
        xz
        nixfmt
        python3
      ];
      baseJailOptions = agentJailOptions ++ [ gitSshJailOptions ];
    })
  ];
}
