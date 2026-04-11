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
}
