{ ... }: {
  # Power management daemon
  services.upower.enable = true;

  # CPU frequency scaling (battery vs performance)
  services.auto-cpufreq = {
    enable = true;
    settings = {
      battery = {
        governor = "powersave";
        turbo = "auto";
      };
      charger = {
        governor = "performance";
        turbo = "auto";
      };
    };
  };

  # Conflicts with auto-cpufreq
  services.power-profiles-daemon.enable = false;

  # Auto-tune power saving (USB, PCI, SATA, etc.)
  powerManagement.powertop.enable = true;

  # Prevent system freeze on low memory
  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5;
    freeSwapThreshold = 10;
  };

  # Distribute interrupts across CPUs
  services.irqbalance.enable = true;
}
