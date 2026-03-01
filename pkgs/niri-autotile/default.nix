{ lib, rustPlatform }:

rustPlatform.buildRustPackage {
  pname = "niri-autotile";
  version = "0.1.0";
  src = ./.;

  cargoLock.lockFile = ./Cargo.lock;

  meta = {
    description = "Auto-tiling daemon for niri";
    mainProgram = "niri-autotile";
  };
}
