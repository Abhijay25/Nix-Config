{ config, pkgs, inputs, ... }:

{
	home.username = "abhijay";
	home.homeDirectory = "/home/abhijay";
	programs.git.enable = true;
	home.stateVersion = "25.11";

	imports = [
		./noctalia.nix
	];

	programs.bash = {
		enable = true;
		shellAliases = {
			btw = "echo I use NixOS btw";
			nrs = "sudo nixos-rebuild switch --flake /home/abhijay/dotfiles#doge";
			
			# Shortcut Aliases
			nc = "vim /home/abhijay/dotfiles/configuration.nix";
			nf = "vim /home/abhijay/dotfiles/flake.nix";
			nh = "vim /home/abhijay/dotfiles/home.nix";
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
    google-fonts
    swww
		roboto
		quickshell
	];
}
