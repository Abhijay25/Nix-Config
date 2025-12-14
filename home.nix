{ config, pkgs, inputs, ... }:

{
	home.username = "abhijay";
	home.homeDirectory = "/home/abhijay";
	home.stateVersion = "25.11";

	imports = [
		./noctalia.nix
  ];

  programs.git.enable = true;
  
  services.swaync.enable = true;
  services.network-manager-applet.enable = true;

  # zsh Config
	programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

		shellAliases = {
			btw = "echo I use NixOS btw";
			nrs = "sudo nixos-rebuild switch --flake /home/abhijay/dotfiles#doge";
			
			# Shortcut Aliases
			nc = "vim /home/abhijay/dotfiles/configuration.nix";
			nf = "vim /home/abhijay/dotfiles/flake.nix";
			nh = "vim /home/abhijay/dotfiles/home.nix";
    };

    oh-my-zsh = {
      enable = true;
      plugins = [ 
        "cp"
        "git"
        "sudo"
        "web-search" ];
      theme = "";
    };
  };

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
  };

  # Config Symlinks
  xdg.configFile."niri/config.kdl".source = config.lib.file.mkOutOfStoreSymlink "/home/abhijay/dotfiles/configs/niri/config.kdl";
  xdg.configFile."ghostty/config".source = config.lib.file.mkOutOfStoreSymlink "/home/abhijay/dotfiles/configs/ghostty/config";
  xdg.configFile."rofi/config.rasi".source = config.lib.file.mkOutOfStoreSymlink "/home/abhijay/dotfiles/configs/rofi/config.rasi";
  xdg.configFile."starship.toml".source = config.lib.file.mkOutOfStoreSymlink "/home/abhijay/dotfiles/configs/starship/starship.toml";

	home.packages = with pkgs; [
    
    # System
    bluez # Bluetooth
    bluez-tools
    gcc
		nixpkgs-fmt
		nodejs
    rofi # Launcher
    unzip
    zip

    # Terminal & NixOS
    btop
    lazygit
    ripgrep

    # Quality of Life
    brightnessctl
    libnotify
    pamixer
    playerctl
    polkit_gnome

    # Utilities
    gpu-screen-recorder
    grim # Screenshot
    slurp
    wl-clipboard # Clipboard Manager
    zathura # PDF Viwer

		# Editor & LSP
		neovim
		nil

    # Ricing & Themes
    adwaita-icon-theme
    fastfetch
    papirus-icon-theme
    swww
    quickshell

    # Browser
    brave

    # Applications
    telegram-desktop
	];
}
