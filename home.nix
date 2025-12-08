{ config, pkgs, ... }:

{
	home.username = "abhijay";
	home.homeDirectory = "/home/abhijay";
	programs.git.enable = true;
	home.stateVersion = "25.11";
	programs.bash = {
		enable = true;
		shellAliases = {
			btw = "echo I use NixOS btw";
			nrs = "sudo nixos-rebuild switch --flake /dotfiles#doge";
			
			# Shortcut Aliases
			nc = "sudo vim /dotfiles/configurations.nix";
			nf = "sudo vim /dotfiles/flakes.nix";
			nh = "sudo vim /dotfiles/home.nix";
		};
	};

	programs.git = {
		enable=true;
		userName = "Abhijay";
		userEmail = "abhijay3852@gmail.com";
	}
	
	home.file".config/niri/config.kdl".source = ./configs/niri/config.kdl;
	home.packages = with pkgs; [
		neovim
		ripgrep
		nil
		nixpkgs-fmt
		nodejs
		gcc
		rofi-wayland
	];
}
