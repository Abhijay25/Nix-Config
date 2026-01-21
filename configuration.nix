{
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Allow Proprietary Apps
  nixpkgs.config.allowUnfree = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "doge"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Network Keyring
  services.gnome.gnome-keyring.enable = true;

  # Enable Keyring on Login
  security.pam.services.login.enableGnomeKeyring = true;

  # Set your time zone.
  time.timeZone = "Asia/Singapore";

  services.xserver.enable = true;

  # Garbage Collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Nix Store Optimisation
  nix.settings.auto-optimise-store = true;

  # Hide Bootloader & Wall of Text on Boot
  boot.loader.timeout = 1;
  boot.plymouth.enable = true;

  # Silence Kernel Text on Boot
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
  ];

  #Login Screen
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    package = pkgs.kdePackages.sddm;
    theme = "sddm-astronaut-theme";

    extraPackages = with pkgs.kdePackages; [
      qtmultimedia
      qtsvg
      qtvirtualkeyboard
      qt5compat
    ];
  };

  hardware.graphics = {
    enable = true;
    # For 32-bit apps (Steam, Wine)
    enable32Bit = true;

    # Install necessary drivers for Intel GPU
    extraPackages = with pkgs; [
      intel-compute-runtime
      intel-media-driver # Hardware Video Acceleration (Broadwell+)
      intel-vaapi-driver # Fallback for older chips
      libvdpau-va-gl
    ];
  };

  # Force the system to use these drivers
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD"; # Force Intel Gen8+ driver
  };

  # Enable Niri
  programs.niri.enable = true;

  # Enable zsh
  programs.zsh.enable = true;

  # Power Management
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  # Bluetooth Enable
  hardware.bluetooth.enable = true;

  xdg.portal = {
    enable = true;

    # Install both the GTK portal (for file pickers) and GNOME portal (for screen recording)
    extraPortals = [pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-gnome];

    # EXPLICIT CONFIGURATION (The Fix)
    config = {
      # For Niri, force usage of the GNOME portal for screencasting
      niri = {
        default = ["gnome" "gtk"];
      };
      # Fallback for anything else
      common = {
        default = ["gtk"];
      };
    };
  };

  security.wrappers.gpu-screen-recorder-core = {
    owner = "root";
    group = "root";
    capabilities = "cap_sys_admin+ep";
    source = "${pkgs.gpu-screen-recorder}/bin/gpu-screen-recorder";
  };

  # File Manager
  programs.thunar.enable = true;

  services.gvfs.enable = true; # Mount USB drives
  services.tumbler.enable = true; # Thumbnail support

  programs.thunar.plugins = with pkgs; [
    thunar-archive-plugin
    thunar-volman
  ];

  # Wireshark
  programs.wireshark.enable = true;
  programs.wireshark.package = pkgs.wireshark;

  # Enable sound
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
  };

  # Docker
  virtualisation.docker.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.abhijay = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = ["networkmanager" "wheel" "video" "audio" "wireshark" "docker"];
    packages = with pkgs; [
      tree
    ];
  };

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    docker-compose
    git
    ghostty
    vim
    wget

    pkgs.gpu-screen-recorder

    (sddm-astronaut.override {
      themeConfig = {
        MainColor = "#ffbbbd";
        AccentColor = "#ffbbbd";

        showPowerButton = "true";
      };
      embeddedTheme = "pixel_sakura";
    })
  ];

  fonts.packages = with pkgs; [
    inter
    nerd-fonts.jetbrains-mono
    roboto
  ];

  nix.settings.experimental-features = ["nix-command" "flakes"];

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?
}
