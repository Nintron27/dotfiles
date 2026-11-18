# Client side of reaching arx, for the desktops.
#
#   ssh arx              normal login as nintron
#   ssh arx-unlock       unlock prompt at boot, over the LAN
#   ssh arx-unlock-wg    unlock prompt at boot, through the arx-unlock WireGuard tunnel
#   nixos-rebuild switch --flake ~/dotfiles#arx --target-host arx --sudo
#
# Addresses, ports and keys come from settings.nix (hosts.arx).
{ config, lib, settings, ... }:
let
  arx = settings.hosts.arx;
  wg = arx.unlock.wireguard;
  # This machine's entry in the unlock tunnel's peer list, if it has one.
  wgPeer = wg.peers.${config.networking.hostName} or null;

  # Both YubiKeys; SSH uses whichever one is plugged in.
  identityFiles = lib.concatMapStringsSep "\n  " (f: "IdentityFile ${f}") settings.users.nintron.sshIdentityFiles;
in
{
  programs.ssh = {
    extraConfig = ''
      Host arx
        HostName ${arx.lanIp}
        User nintron
        ${identityFiles}
        IdentitiesOnly yes
        # Reuse one connection for 10 minutes, so deploys don't need a
        # security-key tap for every SSH connection nixos-rebuild opens.
        ControlMaster auto
        ControlPath ~/.ssh/cm-%C
        ControlPersist 10m

      Host arx-unlock arx-unlock-wg
        User root
        Port ${toString arx.unlock.sshPort}
        ${identityFiles}
        IdentitiesOnly yes
        # Both routes reach the same initrd SSH server; check its pinned key.
        HostKeyAlias arx-initrd

      Host arx-unlock
        HostName ${arx.lanIp}

      Host arx-unlock-wg
        HostName ${wg.address}
    '';

    # arx's initrd SSH host key (separate from its normal host key), pinned so
    # the unlock prompt is verified from the very first connection.
    knownHosts.arx-initrd = {
      hostNames = [ "arx-initrd" ];
      publicKey = arx.unlock.sshHostKey;
    };
  };

  # WireGuard tunnel to arx's boot-time unlock prompt, on desktops listed in
  # settings.hosts.arx.unlock.wireguard.peers. Only routes the unlock address;
  # all other traffic is untouched.
  #   sudo systemctl start wg-quick-arx-unlock && ssh arx-unlock-wg
  networking.wg-quick.interfaces = lib.mkIf (wgPeer != null) {
    arx-unlock = {
      autostart = false;
      address = [ "${wgPeer.address}/32" ];
      # Generated on this machine with `wg genkey`; never leaves it.
      privateKeyFile = "/etc/wireguard/arx-unlock.key";
      peers = [
        {
          publicKey = wg.publicKey;
          # Public DNS name (hosts/arx/ddns.nix), so this works away from home.
          endpoint = "${arx.domain}:${toString wg.port}";
          allowedIPs = [ "${wg.address}/32" ];
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
