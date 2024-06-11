# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      inputs.home-manager.nixosModules.home-manager
    ];

  # Bootloader.
  boot.loader.grub = {
    enable = true;
    # version = 2;
    device = "nodev";
    useOSProber = true;
    efiSupport = true;
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "igneous"; # Define your hostname

  # Enable experimental features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Stuff for VPN
  #networking.firewall.checkReversePath = "loose";
  networking.wireguard.enable = true;
  services.mullvad-vpn.enable = true; # Sets checkReversPath for you

  # Enable printing
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns = true;
    openFirewall = true;
  };

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

  # Pipewire :D
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  # pulseaudio
  # hardware.pulseaudio.enable = true;
  # hardware.pulseaudio.daemon.config = {
  #   flat-volumes = "no";
  #   resample-method = "speex-float-5";
  #   default-sample-format = "s32le";
  #   default-sample-rate = 48000;
  #   alternate-sample-rate = 44100;
  # };

  # rtl-sdr
  services.udev.packages = [ pkgs.rtl-sdr ];

  # ZSA udev rules
  services.udev.extraRules = ''
    # Rules for Oryx web flashing and live training
    KERNEL=="hidraw*", ATTRS{idVendor}=="16c0", MODE="0664", GROUP="plugdev"
    KERNEL=="hidraw*", ATTRS{idVendor}=="3297", MODE="0664", GROUP="plugdev"

    # Legacy rules for live training over webusb (Not needed for firmware v21+)
      # Rule for all ZSA keyboards
      SUBSYSTEM=="usb", ATTR{idVendor}=="3297", GROUP="plugdev"
      # Rule for the Moonlander
      SUBSYSTEM=="usb", ATTR{idVendor}=="3297", ATTR{idProduct}=="1969", GROUP="plugdev"

    # Keymapp / Wally Flashing rules for the Moonlander and Planck EZ
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", MODE:="0666", SYMLINK+="stm32_dfu"
    # Keymapp Flashing rules for the Voyager
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="3297", MODE:="0666", SYMLINK+="ignition_dfu"
  '';

  # bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # logitech
  hardware.logitech.wireless = {
    enable = true;
    enableGraphical = true;
  };

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # List packages installed in system profile. To search, run:
  # environment.systemPackages = with pkgs; [
    # home-manager
  # ];

  # Homemanager module
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      nintron = import ../../home/home.nix;
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.nintron = {
    isNormalUser = true;
    description = "nintron";
    extraGroups = [ "networkmanager" "wheel" "audio" "plugdev" ];
    packages = with pkgs; [];
  };
  users.users.work = {
    isNormalUser = true;
    description = "work";
    extraGroups = [ "networkmanager" "wheel" "audio" ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # xserver
  services.xserver = {
    enable = true;
    exportConfiguration = true;
    dpi = 100;
    screenSection = ''
      Monitor        "Monitor[0]"
      DefaultDepth    24
      Option         "Stereo" "0"
      Option         "nvidiaXineramaInfoOrder" "DFP-4"
      Option         "metamodes" "DP-2: 2560x1440_144 +1920+0 {ForceCompositionPipeline=On, ForceFullCompositionPipeline=On}, DP-0: 1920x1080_144 +0+360 {ForceCompositionPipeline=On, ForceFullCompositionPipeline=On}"
    '';

    videoDrivers = [ "nvidia" ];

    displayManager.lightdm.enable = true;

    # disable mouse acceleration
    libinput = {
      enable = true;
      mouse.accelProfile = "flat";
    };

    desktopManager.xterm.enable = false;
    desktopManager.session = [
      {
        name = "home-manager";
        start = ''
           ${pkgs.runtimeShell} $HOME/.xsession &
        '';
      }
    ];
  };
  hardware.opengl.enable = true;

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

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

}
