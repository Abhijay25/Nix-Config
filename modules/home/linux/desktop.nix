{
  config,
  pkgs,
  ...
}: {
  # Notification daemon
  services.swaync = {
    enable = true;
    settings = {
      focus-window = false;
    };
  };

  services.network-manager-applet.enable = true;
  services.gnome-keyring.enable = true;

  gtk.enable = true;
  gtk.iconTheme = {
    name = "Papirus";
    package = pkgs.papirus-icon-theme;
  };
  # Pre-load Ghostty terminal daemon
  systemd.user.services.ghostty = {
    Unit = {
      Description = "Ghostty Terminal Daemon";
    };
    Service = {
      ExecStart = "${pkgs.ghostty}/bin/ghostty --initial-window=false";
      Restart = "always";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    Unit = {
      Description = "hyprpolkitagent";
      Wants = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # Config symlinks (mutable — editable without rebuilding)
  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = "source = /home/abhijay/dotfiles/configs/hyprland/hyprland.conf";
  };
  xdg.configFile."ghostty/config".source = config.lib.file.mkOutOfStoreSymlink "/home/abhijay/dotfiles/configs/ghostty/config";
  xdg.configFile."satty/config.toml".source = config.lib.file.mkOutOfStoreSymlink "/home/abhijay/dotfiles/configs/satty/config.toml";
  xdg.configFile."starship.toml".source = config.lib.file.mkOutOfStoreSymlink "/home/abhijay/dotfiles/configs/starship/starship.toml";

  xdg.userDirs.enable = true;
  xdg.userDirs.setSessionVariables = false;

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  # Linux-specific aliases
  programs.zsh.shellAliases = {
    nrs = "sudo -v && nh os switch ~/dotfiles";
    fastfetch = "${config.home.homeDirectory}/dotfiles/configs/brrtfetch/brrtfetch -width 80 -height 60 -multiplier 2.5 -info 'fastfetch --logo-type none' ${config.home.homeDirectory}/dotfiles/configs/brrtfetch/gifs/random/lizard.gif";
    vpn = "nusvpn";
  };
}
