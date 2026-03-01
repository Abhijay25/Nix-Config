{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  home.username = "abhijay";
  home.homeDirectory = "/home/abhijay";
  home.stateVersion = "25.11";

  imports = [
    inputs.noctalia.homeModules.default
    ../programs/nixvim.nix
  ];

  # Noctalia shell
  programs.noctalia-shell.enable = true;

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Abhijay";
        email = "163997617+Abhijay25@users.noreply.github.com";
      };
      init.defaultBranch = "main";
    };
  };

  services.swaync.enable = true;
  services.network-manager-applet.enable = true;
  services.gnome-keyring.enable = true;

  # Zsh
  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";  # XDG-compliant path
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 50000;
      save = 50000;
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
    };

    completionInit = ''
      autoload -Uz compinit
      if [[ -n ''${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
        compinit -d ''${ZDOTDIR}/.zcompdump
      else
        compinit -C -d ''${ZDOTDIR}/.zcompdump
      fi
    '';

    initContent = lib.mkBefore ''
      export ZSH_DISABLE_COMPFIX="true"
      zstyle ':completion:*' menu select
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
      # Move fzf file-search from Ctrl+T (taken by ghostty new-tab) to Ctrl+F
      bindkey -r '^T'
      bindkey '^F' fzf-file-widget
    '';

    shellAliases = {
      btw = "echo I use Nix btw";
      nrs = "sudo -v && nh os switch ~/dotfiles";
      flakeupdate = "~/dotfiles/scripts/update-flake.sh";
      fastfetch = "/home/abhijay/dotfiles/configs/brrtfetch/brrtfetch -width 80 -height 60 -multiplier 2.5 -info 'fastfetch --logo-type none' /home/abhijay/dotfiles/configs/brrtfetch/gifs/random/lizard.gif";
      vpn = "nusvpn";
    };
  };

  # Starship prompt
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  # Pre-load Ghostty
  systemd.user.services.ghostty = {
    Unit = {
      Description = "Ghostty Terminal Daemon";
    };
    Service = {
      ExecStart = "${pkgs.ghostty}/bin/ghostty --initial-window=false"; # start server, no window
      Restart = "always";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # Pre-warm rofi (file cache + drun cache)
  systemd.user.services.rofi-prewarm = {
    Unit = {
      Description = "Pre-warm rofi caches";
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeShellScript "rofi-prewarm" ''
        # Wait for desktop to settle
        sleep 2

        # Generate file cache
        ${pkgs.fd}/bin/fd --type f --hidden --max-depth 6 \
          --exclude .git --exclude node_modules \
          --exclude .cache --exclude .nix-defexpr --exclude .nix-profile \
          --exclude .local/share --exclude .mozilla --exclude .cargo \
          --base-directory "$HOME" > /tmp/rofi-file-cache 2>/dev/null

        # Pre-warm rofi (launches and exits in ~100ms, barely visible)
        ${pkgs.coreutils}/bin/timeout 0.1 ${pkgs.rofi}/bin/rofi -show drun || true
      ''}";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  systemd.user.timers.rofi-prewarm = {
    Unit = {
      Description = "Refresh rofi file cache periodically";
    };
    Timer = {
      OnUnitActiveSec = "5m";
    };
    Install = {
      WantedBy = [ "timers.target" ];
    };
  };

  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    Unit = {
      Description = "polkit-gnome-authentication-agent-1";
      Wants = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config = {
      global = {
        hide_env_diff = true;
      };
    };
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
  };

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y";
    settings = {
      manager = {
        ratio = [ 1 2 6 ];
        sort_by = "natural";
        sort_sensitive = false;
        sort_reverse = false;
        sort_dir_first = true;
        linemode = "size";
        show_hidden = false;
        show_symlink = true;
      };
      preview = {
        max_width = 4096;
        max_height = 4096;
      };
    };
    keymap = {
      manager.prepend_keymap = [
        { on = [ "q" ]; run = "quit"; desc = "Exit yazi"; }
        { on = [ "<Esc>" ]; run = "escape"; desc = "Cancel operation"; }
      ];
    };
  };

  # Config symlinks
  xdg.configFile."niri/config.kdl".source = config.lib.file.mkOutOfStoreSymlink "/home/abhijay/dotfiles/configs/niri/config.kdl";
  xdg.configFile."ghostty/config".source = config.lib.file.mkOutOfStoreSymlink "/home/abhijay/dotfiles/configs/ghostty/config";
  xdg.configFile."rofi/config.rasi".source = config.lib.file.mkOutOfStoreSymlink "/home/abhijay/dotfiles/configs/rofi/config.rasi";
  xdg.configFile."rofi/scripts".source = config.lib.file.mkOutOfStoreSymlink "/home/abhijay/dotfiles/scripts";
  xdg.configFile."starship.toml".source = config.lib.file.mkOutOfStoreSymlink "/home/abhijay/dotfiles/configs/starship/starship.toml";

  # XDG user directories
  xdg.enable = true;
  xdg.userDirs.enable = true;

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    EDITOR = "nvim";
  };

  home.packages = with pkgs; [
    # System
    bluez
    bluez-tools
    gcc
    ffmpeg
    nixpkgs-fmt
    nodejs
    polkit_gnome
    rofi
    unzip
    zip

    # Terminal & NixOS
    btop
    fd
    lazygit
    nh
    ripgrep

    # Quality of Life
    brightnessctl
    libnotify
    pamixer
    playerctl

    # Utilities
    grim
    slurp
    wl-clipboard
    zathura

    # Editor & Languages
    claude-code
    code-cursor
    go
    gnumake
    nil
    tinymist
    typst

    # Coding
    yarn

    # Ricing & Themes
    adwaita-icon-theme
    expect
    fastfetch
    papirus-icon-theme
    swww
    util-linux
    quickshell

    # Applications
    localsend
    telegram-desktop
    vesktop
    spotify

    (brave.override {
      commandLineArgs = [
        "--enable-features=UseOzonePlatform"
        "--ozone-platform=wayland"
        "--password-store=basic"
        "--ignore-gpu-blocklist"
        "--enable-gpu-rasterization"
        "--enable-zero-copy"
        "--enable-features=VaapiVideoDecoder,VaapiVideoEncoder,CanvasOopRasterization"
      ];
    })
  ];
}
