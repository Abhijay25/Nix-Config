#!/usr/bin/env bash
set -e
nix flake update --flake "$HOME/dotfiles"
echo "Done. Run 'nrs' to rebuild."
