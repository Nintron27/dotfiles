# arx: headless homelab server (NAS, Hytale server, remote work box).
{ inputs, lib, pkgs, settings, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
    ./initrd-unlock.nix
    ./ddns.nix
    ./vpn.nix

    ../common/base
  ];

  networking.hostName = "arx";

  # Encrypted secrets (decrypted with this host's SSH host key); see .sops.yaml.
  sops.defaultSopsFile = ../../secrets/arx.yaml;

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

  # Terminfo for every terminal (ghostty, alacritty, ...), so TUIs over SSH
  # know what the connecting terminal supports.
  environment.enableAllTerminfo = true;

  # Swap in compressed RAM rather than on a disk partition.
  zramSwap.enable = true;

  # ── Access ────────────────────────────────────────────────────────────
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      # Root only with the YubiKeys, for deploys (`--target-host arx-root`).
      PermitRootLogin = "prohibit-password";
      # Let clients pass their truecolor support (see arx-client.nix SendEnv).
      AcceptEnv = [ "COLORTERM" ];
    };
  };

  users.users.nintron = {
    isNormalUser = true;
    description = "nintron";
    extraGroups = [ "wheel" "networkmanager" ];
    openssh.authorizedKeys.keys = settings.users.nintron.sshKeys;
  };
  # Professional work. Same YubiKeys; deliberately not in wheel, since
  # administering arx happens as nintron.
  users.users.work = {
    isNormalUser = true;
    description = "work";
    openssh.authorizedKeys.keys = settings.users.nintron.sshKeys;
  };

  # Same terminal environment as the desktops (fish, helix, zellij, dev
  # tools, agents); the graphical half of homes/common is skipped.
  home-manager = {
    extraSpecialArgs = {
      inherit inputs settings;
      isArgentum = false;
      headless = true;
    };
    users.nintron.imports = [
      ../../homes/nintron/home.nix
      inputs.catppuccin.homeModules.catppuccin
    ];
    users.work.imports = [
      ../../homes/work/home.nix
      inputs.catppuccin.homeModules.catppuccin
    ];
  };

  # Deploys go straight to root over SSH, so no user needs to be a trusted
  # Nix user (that would be root-equivalent, and the agent jail refuses it).
  users.users.root.openssh.authorizedKeys.keys = settings.users.nintron.sshKeys;

  # Login is key-only (no account password exists), so let wheel use sudo
  # without one for day-to-day admin.
  security.sudo.wheelNeedsPassword = false;

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
