{
  config,
  pkgs,
  lib,
  ...
}: {
  home.username = "abhijay";
  home.homeDirectory = "/home/abhijay";
  home.stateVersion = "25.11";

  imports = [
    ./noctalia.nix
  ];

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

  # zsh Config
  programs.zsh = {
    enable = true;
    enableCompletion = false;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Replace AutoSuggestion
    completionInit = "autoload -U compinit && compinit -u -C";

    # Skip Security Check for Files
    initContent = lib.mkBefore ''
      export ZSH_DISABLE_COMPFIX="true"
    '';

    shellAliases = {
      btw = "echo I use NixOS btw";
      nrs = "sudo nixos-rebuild switch --flake /home/abhijay/dotfiles#doge";

      # Shortcut Aliases
      nc = "vim /home/abhijay/dotfiles/configuration.nix";
      nh = "vim /home/abhijay/dotfiles/home.nix";

      fastfetch = "/home/abhijay/dotfiles/configs/brrtfetch/brrtfetch -width 80 -height 60 -multiplier 2.5 -info 'fastfetch --logo-type none' /home/abhijay/dotfiles/configs/brrtfetch/gifs/random/lizard.gif";
    };
  };

  # Terminal Customization
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  # Pre-Load Ghostty (Faster Launch)
  systemd.user.services.ghostty = {
    Unit = {
      Description = "Ghostty Terminal Daemon";
    };
    Service = {
      # This command starts the server
      ExecStart = "${pkgs.ghostty}/bin/ghostty --initial-window=false";
      Restart = "always";
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };

  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    Unit = {
      Description = "polkit-gnome-authentication-agent-1";
      Wants = ["graphical-session.target"];
      After = ["graphical-session.target"];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
    Install = {
      WantedBy = ["graphical-session.target"];
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

  # Terminal Browsing
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # File Searching
  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
  };

  # NixOS Environment Switch
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;

    config = {
      global = {
        hide_env_diff = true; # Hides the giant wall of variable text
      };
    };
  };

  # VSCode
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
  };

  # Config Symlinks
  xdg.configFile."niri/config.kdl".source = config.lib.file.mkOutOfStoreSymlink "/home/abhijay/dotfiles/configs/niri/config.kdl";
  xdg.configFile."ghostty/config".source = config.lib.file.mkOutOfStoreSymlink "/home/abhijay/dotfiles/configs/ghostty/config";
  xdg.configFile."rofi/config.rasi".source = config.lib.file.mkOutOfStoreSymlink "/home/abhijay/dotfiles/configs/rofi/config.rasi";
  xdg.configFile."starship.toml".source = config.lib.file.mkOutOfStoreSymlink "/home/abhijay/dotfiles/configs/starship/starship.toml";

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";

    EDITOR = "vim";
  };

  home.packages = with pkgs; [
    # System
    bluez # Bluetooth
    bluez-tools
    gcc
    ffmpeg
    nixpkgs-fmt
    nodejs
    polkit_gnome
    rofi # Launcher
    unzip
    zip

    # Terminal & NixOS
    btop
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
    grim # Screenshot
    slurp
    wl-clipboard # Clipboard Manager
    zathura # PDF Viwer

    # Editor & Languages
    claude-code
    code-cursor
    go
    neovim
    nil # LSP for Nix
    tinymist # LSP for typst
    typst

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

    (writeShellScriptBin "gpu-screen-recorder" ''
      # Call the RENAMED system wrapper
      exec /run/wrappers/bin/gpu-screen-recorder-core -w portal "$@"
    '')

    # Hardware Acceleration for Brave
    (brave.override {
      commandLineArgs = [
        # Force Wayland (Essential for Niri)
        "--enable-features=UseOzonePlatform"
        "--ozone-platform=wayland"

        # Stop KWallet Search
        "--password-store=basic"

        # Unblock the GPU (Fixes 'Disabled via blocklist')
        "--ignore-gpu-blocklist"
        "--enable-gpu-rasterization"
        "--enable-zero-copy"

        # Force Hardware Video Decoding (Saves battery on YouTube)
        "--enable-features=VaapiVideoDecoder,VaapiVideoEncoder,CanvasOopRasterization"
      ];
    })
  ];
}
