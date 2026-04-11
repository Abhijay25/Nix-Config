{ pkgs, ... }: {
  # System-wide packages available to all users
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    nix-output-monitor
  ];
}
