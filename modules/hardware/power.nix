{ ... }: {
  services.upower.enable = true;
  services.auto-cpufreq.enable = true;
  services.power-profiles-daemon.enable = false; # Conflicts with auto-cpufreq
}
