{ pkgs, ... }:

{
  systemd.user.services.niri-autotile = {
    description = "Niri auto-tiling daemon";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.niri-autotile}/bin/niri-autotile";
      Restart = "on-failure";
      RestartSec = "5s";

      # Security hardening
      CapabilityBoundingSet = "";
      IPAddressDeny = "any";
      MemoryDenyWriteExecute = true;
      NoNewPrivileges = true;
      PrivateDevices = true;
      PrivateNetwork = true;
      PrivateTmp = true;
      PrivateUsers = true;
      ProtectHome = "read-only";
      ProtectSystem = "strict";
      RestrictAddressFamilies = [ "AF_UNIX" ];
      SystemCallFilter = "@system-service";
      UMask = "0077";
    };
  };
}
