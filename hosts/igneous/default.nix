
# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix

      ../common
      ../features/logitech.nix
    ];

  # Bootloader.
  catppuccin.grub.enable = true;
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    useOSProber = true;
    efiSupport = true;
  };
  boot.loader.efi.canTouchEfiVariables = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "igneous"; # Define your hostname
  # Allow LocalSend
  networking.firewall.allowedUDPPorts = [ 53317 ];
  networking.firewall.allowedTCPPorts = [ 53317 ];

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

  # rtl-sdr
  services.udev.packages = [ pkgs.rtl-sdr pkgs.finalmouse-udev-rules ];

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
      isArgentum = false;
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

  # TODO: Disable mouse debouncing
  environment.etc."libinput/local-overrides.quirks".text = ''
  [Your Mouse Name]
  MatchName=Finalmouse UltralightX dongle Mouse
  ModelBouncingKeys=1
  '';

  # xserver
  services.xserver = {
    enable = true;
    videoDrivers = [ "amdgpu" ];

    displayManager.lightdm.enable = false;
    desktopManager.xterm.enable = false;
  };
  hardware.graphics.enable = true;

  # GVFS for Samba
  services.gvfs.enable = true;

  # dconf for Gnome packages
  programs.dconf.enable = true;

  # Enable FISH systemwide
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

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
