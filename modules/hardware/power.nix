{ ... }: {
  # Power management
  services.upower.enable = true;

  # TLP
  services.tlp = {
    enable = true;
    settings = {
      # CPU frequency scaling
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;

      # Charge thresholds to preserve battery health
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;

      # ThinkPad firmware power profile
      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "low-power";

      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "on";
      RUNTIME_PM_ON_AC = "on";
      RUNTIME_PM_ON_BAT = "auto";
      WOL_DISABLE = "Y";
      USB_AUTOSUSPEND = 1;
      DISK_IDLE_SECS_ON_BAT = 2;

      # Sound card power saving when audio is idle
      SOUND_POWER_SAVE_ON_BAT = 1;
      SOUND_POWER_SAVE_ON_AC = 0;

    };
  };

  # Disabled — conflicts with TLP
  services.auto-cpufreq.enable = false;
  services.power-profiles-daemon.enable = false;

  # Powertop
  powerManagement.powertop.enable = true;

  # Kill processes on critically low memory
  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5;
    freeSwapThreshold = 10;
  };

  # IRQ balancing
  services.irqbalance.enable = true;

  # WiFi power saving
  networking.networkmanager.wifi.powersave = true;

  # Reduce disk wake-ups
  boot.kernel.sysctl = {
    "vm.dirty_writeback_centisecs" = 6000;
    "vm.laptop_mode" = 5;
  };

  # ThinkPad-specific undervolting guard
  services.throttled.enable = true;
}
