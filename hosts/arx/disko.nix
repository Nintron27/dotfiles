# Disk layout for arx, applied by disko during `nixos-anywhere`.
#
#   rpool    1TB 990 EVO Plus   OS (/, /nix, /home)      passphrase, unlocked over SSH in initrd
#   flash    2TB 990 EVO        fast SSD storage         keyfile stored inside rpool
#   scratch  250GB 850 EVO      misc SSD storage         keyfile stored inside rpool
#   ironbank 3x6TB RAIDZ1       NAS data                 keyfile stored inside rpool
#
# !!! Applying this WIPES every disk listed below. !!!
#
# Encryption keys at install time (uploaded by nixos-anywhere --disk-encryption-keys):
#   /tmp/rpool.passphrase           -> rpool passphrase; keylocation is switched to
#                                      `prompt` after creation so it's asked at boot
#   /etc/zfs/keys/<pool>.key        -> 64 hex chars; also copied into the installed
#                                      system via --extra-files so pools unlock at boot
let
  byId = id: "/dev/disk/by-id/${id}";

  # Shared settings for every pool.
  poolOptions = {
    ashift = "12";
    autotrim = "on";
  };
  fsOptions = {
    compression = "zstd";
    acltype = "posixacl";
    xattr = "sa";
    atime = "off";
    dnodesize = "auto";
    normalization = "formD";
    mountpoint = "none";
    "com.sun:auto-snapshot" = "false";
  };
  keyfileEncryption = pool: {
    encryption = "aes-256-gcm";
    keyformat = "hex";
    keylocation = "file:///etc/zfs/keys/${pool}.key";
  };

  # A whole disk given entirely to a ZFS pool.
  zfsDisk = id: pool: {
    type = "disk";
    device = byId id;
    content = {
      type = "gpt";
      partitions.zfs = {
        size = "100%";
        content = {
          type = "zfs";
          inherit pool;
        };
      };
    };
  };

  # A data pool on keyfile encryption with one dataset mounted at `mountpoint`.
  # `nofail` keeps a broken data pool from dropping the headless server into
  # emergency mode; it simply boots without that mount.
  dataPool = { name, mode ? "", dataset, mountpoint }: {
    type = "zpool";
    inherit mode;
    options = poolOptions;
    rootFsOptions = fsOptions // keyfileEncryption name;
    datasets.${dataset} = {
      type = "zfs_fs";
      inherit mountpoint;
      mountOptions = [ "nofail" ];
    };
  };
in
{
  disko.devices = {
    disk = {
      os = {
        type = "disk";
        device = byId "nvme-Samsung_SSD_990_EVO_Plus_1TB_S7U5NJ0Y822348W";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "fmask=0077" "dmask=0077" ];
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "rpool";
              };
            };
          };
        };
      };

      flash = zfsDisk "nvme-Samsung_SSD_990_EVO_2TB_S7M4NL0Y302027V" "flash";
      scratch = zfsDisk "ata-Samsung_SSD_850_EVO_250GB_S2R5NB0HA79097T" "scratch";

      hdd1 = zfsDisk "ata-ST6000VN006-2ZM186_ZVX07FFP" "ironbank";
      hdd2 = zfsDisk "ata-ST6000VN006-2ZM186_ZVX08WFZ" "ironbank";
      hdd3 = zfsDisk "ata-ST6000VN006-2ZM186_ZVX08WKS" "ironbank";
    };

    zpool = {
      rpool = {
        type = "zpool";
        options = poolOptions;
        rootFsOptions = fsOptions // {
          encryption = "aes-256-gcm";
          keyformat = "passphrase";
          keylocation = "file:///tmp/rpool.passphrase";
        };
        # Ask for the passphrase at boot instead of reading the install-time file.
        postCreateHook = ''
          zfs set keylocation=prompt rpool
        '';
        datasets = {
          root = {
            type = "zfs_fs";
            mountpoint = "/";
          };
          nix = {
            type = "zfs_fs";
            mountpoint = "/nix";
          };
          home = {
            type = "zfs_fs";
            mountpoint = "/home";
          };
          # Empty, unmounted dataset holding back 20G so a full pool can still
          # be recovered (delete/shrink this to free space in an emergency).
          reserved = {
            type = "zfs_fs";
            options = {
              mountpoint = "none";
              refreservation = "20G";
            };
          };
        };
      };

      ironbank = dataPool {
        name = "ironbank";
        mode = "raidz1";
        dataset = "nas";
        mountpoint = "/srv/nas";
      };
      flash = dataPool {
        name = "flash";
        dataset = "data";
        mountpoint = "/srv/flash";
      };
      scratch = dataPool {
        name = "scratch";
        dataset = "data";
        mountpoint = "/srv/scratch";
      };
    };
  };
}
