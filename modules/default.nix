{ ... }: {
  imports = [
    # Core
    ./core/boot.nix
    ./core/networking.nix
    ./core/nix.nix
    ./core/packages.nix
    ./core/system.nix

    # Hardware
    ./hardware/graphics.nix
    ./hardware/audio.nix
    ./hardware/bluetooth.nix
    ./hardware/power.nix

    # Desktop
    ./desktop/niri.nix
    ./desktop/niri-autotile.nix
    ./desktop/sddm.nix
    ./desktop/portal.nix
    ./desktop/theming.nix
    ./desktop/keyring.nix

    # Programs
    ./programs/shell.nix
    ./programs/wireshark.nix

    # Services
    ./services/docker.nix

    # Users
    ./users/system.nix
  ];
}
