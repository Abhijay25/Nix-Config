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

  # Zsh config
  programs.zsh = {
    enable = true;
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
      if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
        compinit
      else
        compinit -C
      fi
    '';

    initContent = lib.mkBefore ''
      export ZSH_DISABLE_COMPFIX="true"
      zstyle ':completion:*' menu select
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
    '';

    shellAliases = {
      btw = "echo I use Nix btw";
      nrs = "sudo nixos-rebuild switch --flake ~/dotfiles |& nom";
      nc = "vim /home/abhijay/dotfiles/modules";
      nh = "vim /home/abhijay/dotfiles/modules/users/abhijay.nix";
      fastfetch = "/home/abhijay/dotfiles/configs/brrtfetch/brrtfetch -width 80 -height 60 -multiplier 2.5 -info 'fastfetch --logo-type none' /home/abhijay/dotfiles/configs/brrtfetch/gifs/random/lizard.gif";
    };
  };

  # Terminal customization
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
      ExecStart = "${pkgs.ghostty}/bin/ghostty --initial-window=false";
      Restart = "always";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # Pre-cache file list for rofi (runs on login, refreshes every 5 min)
  systemd.user.services.rofi-file-cache = {
    Unit = {
      Description = "Pre-generate rofi file search cache";
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeShellScript "rofi-cache-gen" ''
        ${pkgs.fd}/bin/fd --type f --hidden --max-depth 6 \
          --exclude .git --exclude node_modules \
          --exclude .cache --exclude .nix-defexpr --exclude .nix-profile \
          --exclude .local/share --exclude .mozilla --exclude .cargo \
          --base-directory "$HOME" > /tmp/rofi-file-cache 2>/dev/null
      ''}";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  systemd.user.timers.rofi-file-cache = {
    Unit = {
      Description = "Refresh rofi file cache periodically";
    };
    Timer = {
      OnUnitActiveSec = "5m";
      OnBootSec = "1m";
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

  programs.vim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      vim-nix
      auto-pairs
      vim-lastplace
    ];
    extraConfig = ''
      " Visuals
      set number
      syntax on

      " Indentation
      set autoindent
      set smartindent

      " Tabs & Spaces
      set expandtab
      set tabstop=2
      set shiftwidth=2

      " Searching
      set ignorecase
      set smartcase
    '';
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
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
    EDITOR = "vim";
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
    ripgrep
    yazi

    # Quality of Life
    brightnessctl
    libnotify
    pamixer
    playerctl
    polkit_gnome

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
    neovim
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
    obsidian
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
