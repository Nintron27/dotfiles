
# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, config, pkgs, pkgs-unstable, ... }:

{
  imports =
    [
      ./hardware-configuration.nix

      ../common/global
    ];

  # Bootloader.
  boot.loader.grub = {
    enable = true;
    # version = 2;
    device = "nodev";
    useOSProber = true;
    efiSupport = true;

    catppuccin = {
      enable = true;
      flavor = "mocha";
    };
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "igneous"; # Define your hostname

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

  # rtl-sdr
  services.udev.packages = [ pkgs.rtl-sdr ];

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

  # Homemanager module
  home-manager = {
    extraSpecialArgs = { 
      inherit inputs;
      inherit pkgs-unstable;
    };
    users.nintron.imports = [
      ../../homes/nintron/home.nix
      inputs.catppuccin.homeManagerModules.catppuccin
    ];
    users.work.imports = [
      ../../homes/work/home.nix
      inputs.catppuccin.homeManagerModules.catppuccin
    ];
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

  
    services.displayManager.sddm = {
      enable = true;
      catppuccin = {
        enable = true;
        font = "Fira Code";
      };
      # Fix wrong Qt version
      package = pkgs.kdePackages.sddm;
    };

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

    # displayManager.lightdm = {
    #   enable = true;
    #   greeters.gtk = {
    #     enable = true;
    #     cursorTheme = {
    #       package = pkgs.catppuccin-cursors.mochaLight;
    #       name = "catppuccin-mocha-dark-cursors";
    #       size = 24;
    #     };
    #   };
    # };

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

  # nvidia crap
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  hardware.nvidia.modesetting.enable = true;

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
