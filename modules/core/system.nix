{ ... }: {
  # SSD optimization
  services.fstrim.enable = true;

  # Swap compression (better than disk swap)
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  # Firmware updates
  services.fwupd.enable = true;

  # Memory management tweaks
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "vm.vfs_cache_pressure" = 50;
  };
}
