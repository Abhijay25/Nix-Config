{ ... }: {
  virtualisation.docker = {
    enable = true;

    # Fix: Docker IPs that don't conflict with NUS WiFi
    daemon.settings = {
      "bip" = "10.200.0.1/16";
      "default-address-pools" = [
        { "base" = "10.201.0.0/16"; "size" = 24; }
      ];
    };
  };
}
