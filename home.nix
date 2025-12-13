{ config, pkgs, inputs, ... }:

{
	home.username = "abhijay";
	home.homeDirectory = "/home/abhijay";
	programs.git.enable = true;
	home.stateVersion = "25.11";

	imports = [
		./noctalia.nix
	];
  
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
      plugins = [ "git" "sudo"];
      theme = "";
    };
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
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

  # Config Symlinks
  xdg.configFile."niri/config.kdl".source = config.lib.file.mkOutOfStoreSymlink "/home/abhijay/dotfiles/configs/niri/config.kdl";
  xdg.configFile."ghostty/config".source = config.lib.file.mkOutOfStoreSymlink "/home/abhijay/dotfiles/configs/ghostty/config";
  xdg.configFile."starship.toml".source = config.lib.file.mkOutOfStoreSymlink "/home/abhijay/dotfiles/configs/starship/starship.toml";

	home.packages = with pkgs; [
		# System
    gcc
		nixpkgs-fmt
		nodejs
		ripgrep
    rofi

    # Quality of Life
    brightnessctl
    libnotify
    pamixer
    playerctl

		# Editor & LSP
		neovim
		nil

		# Ricing
		fastfetch
    swww
    quickshell

    # Browser
    brave
	];
}
