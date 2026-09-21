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
      "input"      # evdev read on /dev/input/*; OpenScreen needs it to see mouse
                   # clicks for auto-zoom, since Wayland exposes no button state
    ];
    packages = with pkgs; [
      tree
    ];
  };
}
