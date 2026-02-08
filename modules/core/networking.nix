{ ... }: {
  networking.hostName = "doge";

  networking.networkmanager.enable = true;

  # Firewall
  networking.firewall.enable = true;
}
