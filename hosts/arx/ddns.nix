# Keeps arx's DNS name pointed at the home's public IPv4 (Xfinity's can change).
# Checks every 5 minutes; the record is created if it doesn't exist yet.
{ config, settings, ... }:
{
  # Cloudflare API token, scoped to Zone → DNS → Edit on stelo.finance only.
  sops.secrets.cloudflare-api-token = { };

  services.cloudflare-dyndns = {
    enable = true;
    apiTokenFile = config.sops.secrets.cloudflare-api-token.path;
    domains = [ settings.hosts.arx.domain ];
    # DNS only: Cloudflare's proxy can't carry WireGuard or game traffic.
    proxied = false;
    ipv4 = true;
    ipv6 = false;
  };
}
