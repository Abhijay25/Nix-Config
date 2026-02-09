{ ... }: {
  # SSD optimization
  services.fstrim.enable = true;

  # Load TCP BBR module for better network performance
  boot.kernelModules = [ "tcp_bbr" ];

  # Swap compression (better than disk swap)
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  # Firmware updates
  services.fwupd.enable = true;

  # Intel thermal management (prevents throttling)
  services.thermald.enable = true;

  # Real-time scheduling for audio/video (also good for security tools)
  security.rtkit.enable = true;

  # Limit boot entries to prevent /boot from filling up
  boot.loader.systemd-boot.configurationLimit = 10;

  # Auto-deduplicate nix store (saves disk space)
  nix.settings.auto-optimise-store = true;

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # Memory and I/O tweaks
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "vm.vfs_cache_pressure" = 50;
    # Writeback tweaks (less frequent disk writes = better battery)
    "vm.dirty_ratio" = 10;
    "vm.dirty_background_ratio" = 5;
    # Network performance
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
    # Security hardening
    "kernel.kptr_restrict" = 2;
    "kernel.dmesg_restrict" = 1;
  };
}
