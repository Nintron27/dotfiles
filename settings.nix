# Values shared across machines/modules. Available in every NixOS module as
# the `settings` argument (passed via specialArgs in flake.nix).
#
# Only things used in more than one place belong here; single-use values
# (disk IDs, ZFS options, hostId, ...) stay next to the code that uses them.
# Everything here is public: never put secrets in this file (use sops).
{
  users.nintron = {
    sshKeys = [
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIF0byXBSsPic/pQcLK+XcyxWcyGG5lHclvrB3Hq9fnCuAAAAC3NzaDpuaW50cm9u nintron@igneous"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIB/poYjgIGBsxTQUsHy47b8gXmLNhGc9PgXStdfp2aj+AAAAEnNzaDpuaW50cm9uX2JhY2t1cA== nintron@igneous"
    ];
    sshIdentityFiles = [ "~/.ssh/nintron" "~/.ssh/nintron_backup" ];
  };

  hosts.arx = {
    # DHCP reservation
    lanIp = "10.0.0.162";
    # Public name, kept updated by hosts/arx/ddns.nix.
    domain = "arx.stelo.finance";
    # UDP port forwarded on the router. Shared by the unlock tunnel (initrd
    # only) and the main VPN (running system only); they never overlap.
    wireguardPort = 51820;
    # arx's normal SSH host key (/etc/ssh/ssh_host_ed25519_key.pub); pinned on clients.
    sshHostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINo6iaFd8JhePo17S7gueqMaDnrj+oUZwv3Lf1olq4Lb";

    # Boot-time remote unlock
    unlock = {
      sshPort = 2222;
      # initrd's SSH host key
      sshHostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID1FMbjqRaQa3aRXbTIoDlRhC2z+yaYyrOshripqclU2";

      wireguard = {
        prefixLength = 24;
        address = "10.99.0.1";
        publicKey = "a5omECGi7fudcizNorkLKlznvgeMYxWoAAbkdW9eLw4=";
        # Devices allowed to reach the unlock prompt. Each generates its own
        # private key locally; only the public key goes here.
        peers.argentum = {
          address = "10.99.0.2";
          publicKey = "dr4rwLEFdTTXCPbgSbfE6UZ34NPW685XCy5acqYVnwc=";
        };
      };
    };

    # Main WireGuard VPN (hosts/arx/vpn.nix). Split tunnel: peers only route
    # traffic for arx itself through it.
    vpn = {
      prefixLength = 24;
      address = "10.100.0.1";
      # Public half of the `wireguard-private-key` secret in secrets/arx.yaml.
      publicKey = "PH5NC/USs+VAP4aPdJbuhTFunO/qTVwtonUylkzMsiw=";
      # Each device generates its own private key; only the public key goes here.
      peers.argentum = {
        address = "10.100.0.2";
        publicKey = "TODO-argentum-vpn-public-key";
      };
    };
  };
}
