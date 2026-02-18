{ ... }: {
  services.fstrim.enable = true;

  # Build temp files in RAM (faster builds, less SSD wear)
  boot.tmp.useTmpfs = true;

  # TCP BBR congestion control
  boot.kernelModules = [ "tcp_bbr" ];

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  services.fwupd.enable = true;
  services.thermald.enable = true;
  security.rtkit.enable = true;

  # Limit stored boot generations
  boot.loader.systemd-boot.configurationLimit = 10;

  time.timeZone = "Asia/Singapore";

  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "vm.vfs_cache_pressure" = 50;
    # Less frequent writeback = better battery
    "vm.dirty_ratio" = 10;
    "vm.dirty_background_ratio" = 5;
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
    # Security hardening
    "kernel.kptr_restrict" = 2;
    "kernel.dmesg_restrict" = 1;
  };
}
