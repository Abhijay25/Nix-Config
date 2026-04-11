{ ... }: {
  # Increment when nix-darwin asks you to on first install
  system.stateVersion = 6;

  # Set explicitly — nix-darwin requires this
  # Use "aarch64-darwin" for Apple Silicon (M-series)
  # Use "x86_64-darwin" for Intel Mac
  nixpkgs.hostPlatform = "aarch64-darwin";

  time.timeZone = "Asia/Singapore";

  # macOS system defaults
  system.defaults = {
    dock = {
      autohide = true;
      autohide-delay = 0.0;
      autohide-time-modifier = 0.2;
      minimize-to-application = true;
      show-recents = false;
      mru-spaces = false;
    };

    finder = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      FXDefaultSearchScope = "SCcf";   # Search current folder by default
      FXEnableExtensionChangeWarning = false;
      FXPreferredViewStyle = "Nlsv";   # List view
      ShowPathbar = true;
      ShowStatusBar = true;
    };

    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      AppleKeyboardUIMode = 3;           # Full keyboard navigation
      ApplePressAndHoldEnabled = false;  # Key repeat instead of accent menu
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
    };

    trackpad = {
      Clicking = true;       # Tap to click
      TrackpadThreeFingerDrag = true;
    };

    screensaver.askForPasswordDelay = 0;
  };
}
