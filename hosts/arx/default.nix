# arx: headless homelab server (NAS, Hytale server, remote work box).
{ lib, pkgs, ... }:
let
  sshKeys = import ../common/ssh-keys.nix;
in
{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
    ./initrd-unlock.nix

    ../common/base
  ];

  networking.hostName = "arx";

  # ── Boot ──────────────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 20;
  boot.loader.efi.canTouchEfiVariables = true;

  # ── ZFS ───────────────────────────────────────────────────────────────
  boot.supportedFilesystems = [ "zfs" ];
  # Required by ZFS; must be unique per machine. Never change it after install.
  networking.hostId = "6fa04c23";
  # The pools are cleanly imported/exported by this host now, so never force an
  # import (protects against importing a pool another system still has open).
  boot.zfs.forceImportRoot = false;

  services.zfs = {
    autoScrub.enable = true;  # monthly; catches bit rot on the RAIDZ
    trim.enable = true;
  };

  # Swap in compressed RAM rather than on a disk partition.
  zramSwap.enable = true;

  # ── Access ────────────────────────────────────────────────────────────
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  users.users.nintron = {
    isNormalUser = true;
    description = "nintron";
    extraGroups = [ "wheel" "networkmanager" ];
    openssh.authorizedKeys.keys = sshKeys;
  };

  # Login is key-only (no account password exists), so let wheel use sudo
  # without one. Needed for `nixos-rebuild --target-host ... --sudo`.
  security.sudo.wheelNeedsPassword = false;
  # Allow pushing store paths over SSH during remote deploys.
  nix.settings.trusted-users = [ "root" "@wheel" ];

  environment.systemPackages = with pkgs; [
    git
    helix
    htop
    smartmontools
    wireguard-tools
  ];

  # This value determines the NixOS release from which the default settings
  # for stateful data were taken. Leave it at the install-time release.
  system.stateVersion = "26.11";
}
