{ ... }: {
  # Homebrew is managed declaratively via nix-darwin
  # Install Homebrew first manually: https://brew.sh
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";  # Remove unlisted casks/formulae on rebuild
      upgrade = true;
    };

    # CLI tools not in nixpkgs or better sourced from Homebrew
    brews = [
      # "mas"  # Mac App Store CLI — uncomment if you use MAS
    ];

    # GUI applications
    casks = [
      "ghostty"
      "brave-browser"
      "telegram"
      "spotify"
      "localsend"
      # "vesktop"  # Use Discord cask or web app on Mac
    ];
  };
}
