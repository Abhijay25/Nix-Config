{ ... }: {
  networking.hostName = "doge";

  networking.networkmanager.enable = true;
  systemd.services.NetworkManager-wait-online.enable = false;

  # Resolver. On a phone hotspot the only DHCP-provided nameserver is the
  # handset itself, which drops queries often enough to kill a long
  # `nh os switch` fetch. resolved keeps that nameserver primary but falls back
  # to public resolvers when it stops answering, and caches lookups so a blip
  # mid-rebuild does not take out the whole download.
  services.resolved = {
    enable = true;
    settings.Resolve.FallbackDNS = [ "1.1.1.1" "9.9.9.9" ];
  };

  # Firewall
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 53317 ]; # LocalSend
    allowedUDPPorts = [ 53317 ]; # LocalSend discovery
  };
}
