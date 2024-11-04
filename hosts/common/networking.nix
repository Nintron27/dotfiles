{
  networking.networkmanager.enable = true;
  networking.nameservers = [ "1.1.1.1" "1.0.0.1" ];

  # Stuff for VPN
  #networking.firewall.checkReversePath = "loose";
  # networking.wireguard.enable = true;
  # services.mullvad-vpn.enable = true; # Sets checkReversPath for you
}
