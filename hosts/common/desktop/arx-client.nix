# Client side of reaching arx, for the desktops.
#
#   ssh arx              normal login as nintron, over the LAN
#   ssh arx-vpn          normal login, through the arx-vpn WireGuard tunnel
#   ssh arx-unlock       unlock prompt at boot, over the LAN
#   ssh arx-unlock-wg    unlock prompt at boot, through the arx-unlock WireGuard tunnel
#   nixos-rebuild switch --flake ~/dotfiles#arx --target-host arx --sudo
#
#   sudo systemctl start wg-quick-arx-vpn       (or wg-quick-arx-unlock)
#
# Addresses, ports and keys come from settings.nix (hosts.arx).
{ config, lib, settings, ... }:
let
  arx = settings.hosts.arx;
  host = config.networking.hostName;

  # Both YubiKeys; SSH uses whichever one is plugged in.
  identityFiles = lib.concatMapStringsSep "\n  " (f: "IdentityFile ${f}") settings.users.nintron.sshIdentityFiles;

  # A tunnel that only routes arx's address on that network; all other
  # traffic is untouched. Started by hand, since it isn't needed at home.
  # The private key is generated on this machine with `wg genkey` and never
  # leaves it.
  mkTunnel = { name, net }: {
    autostart = false;
    address = [ "${net.peers.${host}.address}/32" ];
    privateKeyFile = "/etc/wireguard/${name}.key";
    peers = [
      {
        publicKey = net.publicKey;
        # Public DNS name (hosts/arx/ddns.nix), so this works away from home.
        endpoint = "${arx.domain}:${toString arx.wireguardPort}";
        allowedIPs = [ "${net.address}/32" ];
        persistentKeepalive = 25;
      }
    ];
  };
  # Only desktops listed as peers in settings.nix get a given tunnel.
  tunnelIfPeer = name: net:
    lib.optionalAttrs (net.peers ? ${host}) { ${name} = mkTunnel { inherit name net; }; };

  isWgKey = key: builtins.match "[A-Za-z0-9+/]{42}[AEIMQUYcgkosw048]=" key != null;
in
{
  programs.ssh = {
    extraConfig = ''
      Host arx arx-vpn arx-unlock arx-unlock-wg
        ${identityFiles}
        IdentitiesOnly yes

      Host arx arx-vpn
        User nintron
        # Same machine either way; check its pinned host key.
        HostKeyAlias arx
        # Reuse one connection for 10 minutes, so deploys don't need a
        # security-key tap for every SSH connection nixos-rebuild opens.
        ControlMaster auto
        ControlPath ~/.ssh/cm-%C
        ControlPersist 10m

      Host arx-unlock arx-unlock-wg
        User root
        Port ${toString arx.unlock.sshPort}
        # Both routes reach the same initrd SSH server; check its pinned key.
        HostKeyAlias arx-initrd

      Host arx arx-unlock
        HostName ${arx.lanIp}

      Host arx-vpn
        HostName ${arx.vpn.address}

      Host arx-unlock-wg
        HostName ${arx.unlock.wireguard.address}
    '';

    # Pinned host keys, so connections are verified from the very first one.
    knownHosts = {
      arx = {
        hostNames = [ "arx" ];
        publicKey = arx.sshHostKey;
      };
      # The initrd's own key, separate from arx's normal one.
      arx-initrd = {
        hostNames = [ "arx-initrd" ];
        publicKey = arx.unlock.sshHostKey;
      };
    };
  };

  networking.wg-quick.interfaces =
    tunnelIfPeer "arx-unlock" arx.unlock.wireguard
    // tunnelIfPeer "arx-vpn" arx.vpn;

  # Catch placeholder or mistyped keys at build time, not after a rebuild.
  assertions = [
    {
      assertion = lib.hasPrefix "ssh-ed25519 " arx.sshHostKey;
      message = "settings.hosts.arx.sshHostKey is not an ssh-ed25519 public key.";
    }
    {
      assertion = isWgKey arx.vpn.publicKey;
      message = "settings.hosts.arx.vpn.publicKey is not a valid WireGuard public key.";
    }
  ];
}
