{
  config,
  pkgs,
  ...
}: {
  # No separate notification daemon: noctalia-shell ships its own and takes
  # org.freedesktop.Notifications on the user bus. Running swaync alongside it
  # made swaync.service fail its D-Bus name grab on every login, which in turn
  # made switch-to-configuration exit 4 and `nrs` report a failed rebuild.

  services.hyprpaper = {
    enable = true;
    settings = {
      wallpaper = [
        {
          monitor = "eDP-1";
          path = "${../shared/wallpapers/Tiger.png}";
        }
      ];
      splash = false;
    };
  };

  services.network-manager-applet.enable = true;
  services.gnome-keyring.enable = true;

  gtk.enable = true;
  gtk.iconTheme = {
    name = "Papirus";
    package = pkgs.papirus-icon-theme;
  };

  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 22;
    hyprcursor = {
      enable = true;
      size = 22;
    };
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
    configType = "lua";
    extraConfig = ''dofile("/home/abhijay/dotfiles/modules/home/shared/configs/hyprland/hyprland.lua")'';
  };
  xdg.configFile."ghostty/config".source = config.lib.file.mkOutOfStoreSymlink "/home/abhijay/dotfiles/modules/home/shared/configs/ghostty/config";
  xdg.configFile."satty/config.toml".source = config.lib.file.mkOutOfStoreSymlink "/home/abhijay/dotfiles/modules/home/shared/configs/satty/config.toml";
  xdg.configFile."starship.toml".source = config.lib.file.mkOutOfStoreSymlink "/home/abhijay/dotfiles/modules/home/shared/configs/starship/starship.toml";

  xdg.userDirs.enable = true;
  xdg.userDirs.setSessionVariables = false;

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  # Linux-specific aliases
  programs.zsh.shellAliases = {
    # --no-nom: the interactive nix-output-monitor TUI is coupled to the
    # controlling terminal, so switching ghostty tabs delivers a focus event
    # that interrupts the build (SIGINT -> "interrupted by the user").
    nrs = "sudo -v && nh os switch --no-nom ~/dotfiles";
    fastfetch = "${config.home.homeDirectory}/dotfiles/modules/home/shared/configs/brrtfetch/brrtfetch -width 80 -height 60 -multiplier 2.5 -info 'fastfetch --logo-type none' ${config.home.homeDirectory}/dotfiles/modules/home/shared/configs/brrtfetch/gifs/random/lizard.gif";
    vpn = "nusvpn";
  };
}
