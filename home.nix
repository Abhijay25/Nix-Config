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
			nrs = "sudo nixos-rebuild switch --flake /home/abhijay/dotfiles#doge";
			
			# Shortcut Aliases
			nc = "vim /home/abhijay/dotfiles/configuration.nix";
			nf = "vim /home/abhijay/dotfiles/flake.nix";
			nh = "vim /home/abhijay/dotfiles/home.nix";
		};
	};

	home.file.".config/niri/config.kdl".source = ./configs/niri/config.kdl;
	home.packages = with pkgs; [
		neovim
		ripgrep
		nil
		nixpkgs-fmt
		nodejs
		gcc
		rofi
	];
}
