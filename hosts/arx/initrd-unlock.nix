# Remote unlock of the encrypted root pool, before the real system boots.
#
# The initrd brings up the LAN (DHCP) plus a dedicated WireGuard tunnel, and
# runs an SSH server on port 2222 that only accepts nintron's keys. Logging in
# drops straight into the ZFS passphrase prompt; once entered, rpool unlocks,
# the other pools unlock from keyfiles stored inside it, and boot continues.
#
#   On the LAN:  ssh -p 2222 root@10.0.0.162
#   Away:        bring up the `arx-unlock` WireGuard profile, then
#                ssh -p 2222 root@10.99.0.1
#
# The secrets below live unencrypted on the ESP (it has to be readable before
# anything is unlocked), so they are *separate* keys used only for this:
#   /etc/secrets/initrd/ssh_host_ed25519_key   initrd SSH host key
#   /etc/secrets/initrd/wg-unlock.key          initrd WireGuard private key
# They are put in place at install time by nixos-anywhere --extra-files and
# must never be committed to this repo.
{ pkgs, ... }:
let
  sshKeys = import ../common/ssh-keys.nix;
  secretsDir = "/etc/secrets/initrd";
  wgKey = "${secretsDir}/wg-unlock.key";

  wgInterface = "wg-unlock";
  wgPort = 51820; # same UDP port the main WireGuard VPN will use later
  wgAddress = "10.99.0.1/24";

  # Devices allowed to reach the unlock prompt over WireGuard.
  wgPeers = [
    {
      # argentum (laptop)
      PublicKey = "dr4rwLEFdTTXCPbgSbfE6UZ34NPW685XCy5acqYVnwc=";
      AllowedIPs = [ "10.99.0.2/32" ];
    }
  ];
in
{
  boot.initrd = {
    # Ethernet driver for the initrd network (arx has a Realtek NIC).
    # nixos-generate-config doesn't detect NICs, so it's listed by hand.
    availableKernelModules = [ "r8169" ];
    kernelModules = [ "wireguard" ];

    secrets.${wgKey} = wgKey;

    network = {
      enable = true;
      # Hand a clean interface to NetworkManager in stage 2.
      flushBeforeStage2 = true;
      ssh = {
        enable = true;
        port = 2222;
        hostKeys = [ "${secretsDir}/ssh_host_ed25519_key" ];
        authorizedKeys = sshKeys;
      };
    };

    systemd = {
      # Logging in goes straight to the passphrase prompt.
      users.root.shell = "/bin/systemd-tty-ask-password-agent";

      network = {
        enable = true;

        networks."10-lan" = {
          matchConfig.Type = "ether";
          networkConfig.DHCP = "yes";
        };

        netdevs."20-${wgInterface}" = {
          netdevConfig = {
            Kind = "wireguard";
            Name = wgInterface;
          };
          wireguardConfig = {
            PrivateKeyFile = wgKey;
            ListenPort = wgPort;
          };
          wireguardPeers = wgPeers;
        };
        networks."20-${wgInterface}" = {
          matchConfig.Name = wgInterface;
          address = [ wgAddress ];
        };
      };

      # systemd-networkd runs as the `systemd-network` user, but initrd secrets
      # are copied in as root-only. Let networkd read the key before it starts.
      services.wg-unlock-key-perms = {
        description = "Make initrd WireGuard key readable by systemd-networkd";
        wantedBy = [ "systemd-networkd.service" ];
        after = [ "initrd-nixos-copy-secrets.service" ];
        before = [ "systemd-networkd.service" ];
        unitConfig.DefaultDependencies = false;
        serviceConfig.Type = "oneshot";
        script = ''
          chgrp systemd-network ${wgKey}
          chmod 0640 ${wgKey}
        '';
      };
    };
  };

  # The WireGuard interface outlives the initrd. Remove it once the real system
  # is up so it doesn't hold UDP ${toString wgPort} for the main VPN.
  systemd.services.remove-initrd-wireguard = {
    description = "Remove the initrd unlock WireGuard interface";
    wantedBy = [ "multi-user.target" ];
    before = [ "network-pre.target" ];
    wants = [ "network-pre.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "-${pkgs.iproute2}/bin/ip link delete ${wgInterface}";
    };
  };
}
