{ ... }: {
  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1;

  # Plymouth
  boot.plymouth.enable = true;

  # Suppress boot messages
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;
  boot.kernelParams = [
    "quiet"
    "splash"
    "boot.shell_on_fail"
    "logLevel=3"
    "rd.systemd.show_status=false"
    "rd.udev.log_level=3"
    "udev.log_priority=3"
    "nowatchdog"
    "nmi_watchdog=0"
    "i915.enable_psr=1"   # Panel self-refresh
    "i915.enable_fbc=1"   # Framebuffer compression
  ];
}
