#!/usr/bin/env bash
set -e

DOTFILES="$HOME/dotfiles"
CARGO_TOML="$DOTFILES/pkgs/niri-autotile/Cargo.toml"

echo "Updating flake inputs..."
nix flake update "$DOTFILES"

echo "Reading niri version from updated nixpkgs..."
NIRI_VERSION=$(nix eval --raw "$DOTFILES#nixosConfigurations.doge.pkgs.niri.version")
echo "niri version: $NIRI_VERSION"

echo "Updating niri-ipc in Cargo.toml..."
sed -i "s/niri-ipc = \"=.*\"/niri-ipc = \"=${NIRI_VERSION}\"/" "$CARGO_TOML"

echo "Regenerating Cargo.lock..."
cd "$DOTFILES/pkgs/niri-autotile"
nix run nixpkgs#cargo -- generate-lockfile

echo "Done. Run 'nrs' to rebuild."
