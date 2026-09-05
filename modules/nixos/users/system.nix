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
      "wireshark"  # dumpcap capture privileges without running the GUI as root
    ];
    packages = with pkgs; [
      tree
    ];
  };
}
