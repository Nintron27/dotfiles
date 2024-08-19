{
  networking.networkmanager.enable = true;

  # Stuff for VPN
  #networking.firewall.checkReversePath = "loose";
  networking.wireguard.enable = true;
  services.mullvad-vpn.enable = true; # Sets checkReversPath for you
}
