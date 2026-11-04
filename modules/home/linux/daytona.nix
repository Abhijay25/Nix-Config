{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
}:
# Daytona CLI (provides `daytona mcp start`). Not in nixpkgs: daytona-bin was removed as
# unmaintained, and releases moved from daytonaio/daytona to daytona/clients. The
# prebuilt binary is dynamically linked against glibc only, so autoPatchelf suffices.
# Kept on the stable v0.x line to match @daytona/sdk; v2.0.0 releases are alphas.
stdenvNoCC.mkDerivation rec {
  pname = "daytona";
  version = "0.227.0";

  src = fetchurl {
    url = "https://github.com/daytona/clients/releases/download/v${version}/daytona-linux-amd64";
    hash = "sha256-m5beVB+iy6VgQ2mLx393VMEiws6rBbb5V0BagWRJ2+0=";
  };

  dontUnpack = true;
  nativeBuildInputs = [autoPatchelfHook];

  installPhase = ''
    install -Dm755 $src $out/bin/daytona
  '';

  meta = {
    description = "Daytona CLI for sandboxes and the Daytona MCP server";
    homepage = "https://github.com/daytona/clients";
    license = lib.licenses.asl20;
    platforms = ["x86_64-linux"];
    mainProgram = "daytona";
  };
}
