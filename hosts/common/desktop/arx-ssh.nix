# SSH client config for reaching arx (system-wide /etc/ssh/ssh_config).
#
#   ssh arx              normal login as nintron
#   ssh arx-unlock       unlock prompt at boot, over the LAN
#   ssh arx-unlock-wg    unlock prompt at boot, through the arx-unlock WireGuard tunnel
#   nixos-rebuild switch --flake ~/dotfiles#arx --target-host arx --sudo
{
  programs.ssh = {
    extraConfig = ''
      Host arx
        HostName 10.0.0.162
        User nintron
        IdentityFile ~/.ssh/nintron
        IdentitiesOnly yes
        # Reuse one connection for 10 minutes, so deploys don't need a
        # security-key tap for every SSH connection nixos-rebuild opens.
        ControlMaster auto
        ControlPath ~/.ssh/cm-%C
        ControlPersist 10m

      Host arx-unlock arx-unlock-wg
        User root
        Port 2222
        IdentityFile ~/.ssh/nintron
        IdentitiesOnly yes
        # Both routes reach the same initrd SSH server; check its pinned key.
        HostKeyAlias arx-initrd

      Host arx-unlock
        HostName 10.0.0.162

      Host arx-unlock-wg
        HostName 10.99.0.1
    '';

    # arx's initrd SSH host key (separate from its normal host key), pinned so
    # the unlock prompt is verified from the very first connection.
    knownHosts.arx-initrd = {
      hostNames = [ "arx-initrd" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID1FMbjqRaQa3aRXbTIoDlRhC2z+yaYyrOshripqclU2";
    };
  };
}
