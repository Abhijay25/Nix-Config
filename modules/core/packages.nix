{ pkgs, ... }: {
  # System-level packages (require root or system integration)
  environment.systemPackages = with pkgs; [
    docker-compose
    git
    ghostty
    vim
    wget
    nix-output-monitor
  ];
}
