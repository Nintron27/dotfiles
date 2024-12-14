
# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, config, pkgs, pkgs-unstable, ... }:

{
  imports =
    [
      ./hardware-configuration.nix

      ../common
    ];

  # Bootloader.
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    useOSProber = true;
    efiSupport = true;

    catppuccin = {
      enable = true;
    };
  };
  boot.loader.efi.canTouchEfiVariables = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "argentum"; # Define your hostname

  # security.polkit.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  systemd.sleep.extraConfig = ''
    HibernateDelaySec=3600s
  '';
  services.logind.lidSwitch = "suspend-then-hibernate";

  services.kmonad = {
   enable = true;
     keyboards = {
       myKMonadOutput = {
         device = "/dev/input/by-path/platform-i8042-serio-0-event-kbd";
         config = builtins.readFile ./keyboard.kbd;
       };
     };
  };

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
  };

  # PAM
  security.pam.services.hyprlock = {};

  # Homemanager module
  home-manager = {
    extraSpecialArgs = { 
      inherit inputs;
      inherit pkgs-unstable;
      isArgentum = true;
    };
    users.nintron.imports = [
      ../../homes/nintron/home.nix
      inputs.catppuccin.homeManagerModules.catppuccin
    ];
    users.work.imports = [
      ../../homes/work/home.nix
      inputs.catppuccin.homeManagerModules.catppuccin
    ];
    # backupFileExtension = "hm-backup";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.nintron = {
    isNormalUser = true;
    description = "nintron";
    extraGroups = [ "networkmanager" "wheel" "audio" "plugdev" ];
  };
  users.users.work = {
    isNormalUser = true;
    description = "work";
    extraGroups = [ "networkmanager" "wheel" "audio" ];
  };

  # libinput
  services.libinput = {
    enable = true;
  };

  # xserver
  services.xserver = {
    enable = true;

    desktopManager.xterm.enable = false;
  };

  services.fwupd.enable = true;
  # we need fwupd 1.9.7 to downgrade the fingerprint sensor firmware
  services.fwupd.package = (import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/bb2009ca185d97813e75736c2b8d1d8bb81bde05.tar.gz";
    sha256 = "sha256:003qcrsq5g5lggfrpq31gcvj82lb065xvr7bpfa8ddsw8x4dnysk";
  }) {
    inherit (pkgs) system;
  }).fwupd;


  # GVFS for Samba
  services.gvfs.enable = true;

  # dconf for Gnome packages
  programs.dconf.enable = true;

  # Steam
  programs.steam = {
    enable = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
