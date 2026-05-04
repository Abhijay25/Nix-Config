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
      "docker"
    ];
    packages = with pkgs; [
      tree
    ];
  };
}
