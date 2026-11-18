# Main WireGuard VPN: reach arx (NAS, SSH, services) from anywhere.
#
# Split tunnel: peers only send traffic for arx's VPN address through it; the
# rest of their traffic is untouched. Addresses and public keys live in
# settings.nix (hosts.arx.vpn); the server's private key is in sops.
{ config, lib, settings, ... }:
let
  arx = settings.hosts.arx;
  vpn = arx.vpn;
  isWgKey = key: builtins.match "[A-Za-z0-9+/]{42}[AEIMQUYcgkosw048]=" key != null;
in
{
  sops.secrets.wireguard-private-key = { };

  networking.firewall.allowedUDPPorts = [ arx.wireguardPort ];

  networking.wireguard.interfaces.wg0 = {
    ips = [ "${vpn.address}/${toString vpn.prefixLength}" ];
    listenPort = arx.wireguardPort;
    privateKeyFile = config.sops.secrets.wireguard-private-key.path;
    peers = lib.mapAttrsToList (name: peer: {
      inherit name;
      inherit (peer) publicKey;
      allowedIPs = [ "${peer.address}/32" ];
    }) vpn.peers;
  };

  # The initrd unlock tunnel uses the same UDP port; make sure it's gone first.
  systemd.services.wireguard-wg0 = {
    after = [ "remove-initrd-wireguard.service" ];
    wants = [ "remove-initrd-wireguard.service" ];
  };

  # Catch placeholder or mistyped keys at build time, not after a deploy.
  assertions = lib.mapAttrsToList (name: peer: {
    assertion = isWgKey peer.publicKey;
    message = "settings.hosts.arx.vpn.peers.${name}.publicKey is not a valid WireGuard public key.";
  }) vpn.peers ++ [{
    assertion = isWgKey vpn.publicKey;
    message = "settings.hosts.arx.vpn.publicKey is not a valid WireGuard public key.";
  }];
}
