# Git identity, SSH commit signing and SSH transport for a jailed agent.
#
# The jail never sees ~/.ssh or the normal host ssh-agent. Instead a
# dedicated agent (systemd user service `ssh-agent-jail`, socket
# $XDG_RUNTIME_DIR/ssh-agent-jail) holds a single key, ~/.ssh/jail_ed25519,
# registered on GitHub as both an authentication and a signing key. Revoke it
# on GitHub to cut the jail off without touching your other keys.
#
# One-time host setup:
#   ssh-keygen -t ed25519 -N "" -C "jail@$(hostname)" -f ~/.ssh/jail_ed25519
#   gh auth refresh -s admin:public_key,admin:ssh_signing_key
#   gh ssh-key add ~/.ssh/jail_ed25519.pub --type authentication --title "jail $(hostname)"
#   gh ssh-key add ~/.ssh/jail_ed25519.pub --type signing        --title "jail $(hostname)"
#   systemctl --user restart ssh-agent-jail
#
# Everything is optional at runtime: if the agent socket or the public key is
# missing the jail still starts; ssh then has no credentials and signed
# commits fail loudly (rather than silently landing unsigned).
{
  pkgs,
  combinators,
  userName,
  userEmail,
}:

let
  inherit (combinators)
    compose
    add-pkg-deps
    add-runtime
    add-cleanup
    write-text
    set-env
    ;

  # Bound into the jail by the runtime below (paths inside the jail).
  jailAgentSock = "/run/jail/ssh-agent.sock";
  jailSigningPub = "/run/jail/signing-key.pub";
  jailAllowedSigners = "/run/jail/allowed_signers";

  gitConfig = ''
    [user]
      name = ${userName}
      email = ${userEmail}
      # Public key only; ssh-keygen signs through the agent.
      signingkey = ${jailSigningPub}
    [gpg]
      format = ssh
    [gpg "ssh"]
      allowedSignersFile = ${jailAllowedSigners}
    [commit]
      gpgsign = true
    [tag]
      gpgsign = true
  '';

  # GitHub's ed25519 host key, from https://api.github.com/meta (ssh_keys).
  # Fingerprint SHA256:+DiY3wvvV6TuJJhbpZisF/zLDA0zPMSvHdkr4UvCOqU, checked against
  # https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints
  githubKnownHosts = ''
    github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
  '';
in
compose [
  # ssh, ssh-add, ssh-keygen (git's default gpg.ssh.program)
  (add-pkg-deps [ pkgs.openssh ])

  # write-text binds the store file *and* adds it to the jail's closure;
  # a bare set-env reference to a store path would not be visible inside.
  (write-text "/run/jail/gitconfig" gitConfig)
  (set-env "GIT_CONFIG_GLOBAL" "/run/jail/gitconfig")

  # nixpkgs openssh uses sysconfdir=/etc/ssh, so this is picked up as
  # GlobalKnownHostsFile with no ssh_config needed.
  (write-text "/etc/ssh/ssh_known_hosts" githubKnownHosts)

  (add-runtime ''
    jail_agent_sock="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/ssh-agent-jail"
    if [ -S "$jail_agent_sock" ]; then
      RUNTIME_ARGS+=(--bind "$jail_agent_sock" ${jailAgentSock})
      RUNTIME_ARGS+=(--setenv SSH_AUTH_SOCK ${jailAgentSock})
    fi

    jail_signing_pub="$HOME/.ssh/jail_ed25519.pub"
    if [ -f "$jail_signing_pub" ]; then
      JAIL_ALLOWED_SIGNERS_HOST=$(mktemp)
      printf '%s namespaces="git" %s\n' ${pkgs.lib.escapeShellArg userEmail} \
        "$(cut -d' ' -f1,2 "$jail_signing_pub")" > "$JAIL_ALLOWED_SIGNERS_HOST"
      RUNTIME_ARGS+=(--ro-bind "$jail_signing_pub" ${jailSigningPub})
      RUNTIME_ARGS+=(--ro-bind "$JAIL_ALLOWED_SIGNERS_HOST" ${jailAllowedSigners})
    fi
  '')

  (add-cleanup ''
    if [ -n "''${JAIL_ALLOWED_SIGNERS_HOST-}" ]; then
      rm -f "$JAIL_ALLOWED_SIGNERS_HOST"
    fi
  '')
]
