{
  networking.networkmanager.enable = true;
  networking.nameservers = [ "1.1.1.1" "1.0.0.1" ];

  # Stuff for VPN
  # networking.firewall.checkReversePath = "loose";
  networking.wireguard.enable = true;
  networking.firewall.checkReversePath = false;
  # services.mullvad-vpn.enable = true; # Sets checkReversPath for you
}
