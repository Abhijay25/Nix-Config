{ ... }: {
  networking.hostName = "doge";

  networking.networkmanager.enable = true;

  # Firewall
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 53317 ]; # LocalSend
    allowedUDPPorts = [ 53317 ]; # LocalSend discovery
  };
}
