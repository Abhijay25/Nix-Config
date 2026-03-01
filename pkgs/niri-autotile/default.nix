{ craneLib }:

let
  common = {
    src = ./.;
    strictDeps = true;
  };

  # Dependencies compiled separately — cached until Cargo.lock changes
  cargoArtifacts = craneLib.buildDepsOnly common;
in
# Only this derivation rebuilds when main.rs changes
craneLib.buildPackage (common // {
  inherit cargoArtifacts;
})
