{ ... }: {
  networking.hostName = "doge";

  networking.networkmanager.enable = true;
  systemd.services.NetworkManager-wait-online.enable = false;

  # Firewall
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 53317 ]; # LocalSend
    allowedUDPPorts = [ 53317 ]; # LocalSend discovery
  };
}
