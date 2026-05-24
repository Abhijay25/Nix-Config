{ ... }: {
  imports = [
    ./hardware-configuration.nix

    # Core
    ../../modules/nixos/core/boot.nix
    ../../modules/nixos/core/networking.nix
    ../../modules/nixos/core/nix.nix
    ../../modules/nixos/core/packages.nix
    ../../modules/nixos/core/system.nix

    # Hardware
    ../../modules/nixos/hardware/graphics.nix
    ../../modules/nixos/hardware/audio.nix
    ../../modules/nixos/hardware/bluetooth.nix
    ../../modules/nixos/hardware/power.nix

    # Desktop
    ../../modules/nixos/desktop/hyprland.nix
    ../../modules/nixos/desktop/sddm.nix
    ../../modules/nixos/desktop/portal.nix
    ../../modules/nixos/desktop/theming.nix
    ../../modules/nixos/desktop/keyring.nix

    # Programs
    ../../modules/nixos/programs/nix-ld.nix
    ../../modules/nixos/programs/shell.nix
    ../../modules/nixos/programs/wireshark.nix

    # Services
    ../../modules/nixos/services/docker.nix
    ../../modules/nixos/services/ollama.nix

    # Users
    ../../modules/nixos/users/system.nix
  ];
}
