{ config, ... }: {
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
      CPU_BOOST_ON_BAT = 1;

      # Floor: ~1.2 GHz on AC (29% of 4.2 GHz), ~0.88 GHz on battery
      CPU_MIN_PERF_ON_AC = 30;
      CPU_MIN_PERF_ON_BAT = 25;

      # Ramp up faster on AC, stay conservative on battery
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";

      # Charge thresholds to preserve battery health
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;

      # ThinkPad firmware power profile
      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "balanced";

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

  # Powertop auto-tune disabled — conflicts with TLP (overrides schedutil governor with powersave)
  # powerManagement.powertop.enable = true;

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

  # The upstream default config sets PL1 (sustained) = 44 W with a 95 C trip temp on AC.
  # The i7-8650U is a 15 W TDP part and the T480s chassis cannot dissipate 44 W sustained,
  # so any load ramped to 44 W and heated until it hit the 95 C ceiling. Since throttled
  # rewrites these MSRs every 5 s, nothing else could lower them.
  #
  # PL1 is the sustained limit (28 s window) — this is what governs steady-state temps.
  # PL2 is the short burst limit, kept high so brief actions still boost to 4.2 GHz.
  #
  # Do NOT enable services.thermald alongside this: both write the same RAPL registers
  # and will fight each other. thermald is fine with TLP, but not with throttled.
  services.throttled.extraConfig = ''
    [GENERAL]
    Enabled: True
    Sysfs_Power_Path: /sys/class/power_supply/AC*/online
    Autoreload: True

    [BATTERY]
    Update_Rate_s: 30
    PL1_Tdp_W: 12
    PL1_Duration_s: 28
    PL2_Tdp_W: 29
    PL2_Duration_S: 0.002
    Trip_Temp_C: 80
    cTDP: 0
    Disable_BDPROCHOT: False

    [AC]
    Update_Rate_s: 5
    PL1_Tdp_W: 20
    PL1_Duration_s: 28
    PL2_Tdp_W: 40
    PL2_Duration_S: 0.002
    Trip_Temp_C: 80
    cTDP: 0
    Disable_BDPROCHOT: False

    [UNDERVOLT.BATTERY]
    CORE: 0
    GPU: 0
    CACHE: 0
    UNCORE: 0
    ANALOGIO: 0

    [UNDERVOLT.AC]
    CORE: 0
    GPU: 0
    CACHE: 0
    UNCORE: 0
    ANALOGIO: 0
  '';

  # The upstream NixOS module writes /etc/throttled.conf but adds no restartTriggers,
  # so a config-only change leaves the daemon running with the old limits in memory.
  # throttled's own Autoreload does not help: NixOS swaps the /etc symlink rather than
  # modifying the file, so the inotify watch on the old inode never fires.
  systemd.services.throttled.restartTriggers = [
    config.environment.etc."throttled.conf".source
  ];

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
  services.logind.settings.Login.HandleLidSwitch = "suspend";
}
