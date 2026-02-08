{ pkgs, ... }: {
  # User account
  users.users.abhijay = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "audio"
      "wireshark"
      "docker"
    ];
    packages = with pkgs; [
      tree
    ];
  };

  # System-wide packages
  environment.systemPackages = with pkgs; [
    docker-compose
    git
    ghostty
    vim
    wget
    nix-output-monitor
  ];

  # Timezone
  time.timeZone = "Asia/Singapore";
}
