{ ... }: {
  # Power management
  services.upower.enable = true;

  # TLP
  services.tlp = {
    enable = true;
    settings = {
      # CPU frequency scaling
      CPU_SCALING_GOVERNOR_ON_AC = "schedutil";
      CPU_SCALING_GOVERNOR_ON_BAT = "schedutil";
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

  # Disable USB wake from suspend (prevents USB subsystem battery drain in S3)
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="pci", ATTR{power/wakeup}="disabled", DRIVER=="xhci_hcd"
  '';

  # Ensure deep sleep (S3) is used, not s2idle
  boot.kernelParams = [ "mem_sleep_default=deep" ];

  # Suspend-then-hibernate: suspends to RAM, then hibernates after 30 min
  # NOTE: Hibernate requires swap >= RAM. Current swap (4GB) < RAM (7.5GB).
  # Uncomment the below after resizing swap partition to 8GB+.
  # systemd.sleep.extraConfig = ''
  #   HibernateDelaySec=30min
  # '';
  # services.logind.lidSwitch = "suspend-then-hibernate";
  # boot.resumeDevice = "/dev/disk/by-uuid/e8c93361-536b-47e6-beba-2a597d1b2a08";

  # For now, just use regular suspend on lid close
  services.logind.lidSwitch = "suspend";
}
