{
  pkgs,
  lib,
  host,
  ...
}:
let
  port = 3003;
  cacheDir = "immich-machine-learning";
in
lib.mkIf (host == "desktop") {
  systemd.services.immich-machine-learning = {
    description = "Immich machine learning worker for the Pi's Immich server";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    environment = {
      MACHINE_LEARNING_CACHE_FOLDER = "/var/cache/${cacheDir}";
      XDG_CACHE_HOME = "/var/cache/${cacheDir}";
      IMMICH_HOST = "0.0.0.0";
      IMMICH_PORT = toString port;
    };
    serviceConfig = {
      ExecStart = lib.getExe pkgs.immich.machine-learning;
      DynamicUser = true;
      CacheDirectory = cacheDir;
      Restart = "on-failure";
      RestartSec = 3;

      CapabilityBoundingSet = "";
      NoNewPrivileges = true;
      PrivateDevices = true;
      PrivateTmp = true;
      PrivateUsers = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
      ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      UMask = "0077";
    };
  };
}
