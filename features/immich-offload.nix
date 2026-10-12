{
  pkgs,
  lib,
  host,
  ...
}:
let
  piAddress = "100.64.0.1";
  piStackDir = "/opt/stacks/documents";
  libraryMount = "/mnt/immich-library";

  immich-offload = pkgs.writeShellApplication {
    name = "immich-offload";
    runtimeInputs = with pkgs; [
      curl
      jq
      openssh
      util-linux
    ];
    runtimeEnv = {
      PI_ADDRESS = piAddress;
      PI_STACK_DIR = piStackDir;
      LIBRARY_MOUNT = libraryMount;
    };
    excludeShellChecks = [ "SC2029" ];
    text = builtins.readFile ./immich-offload.sh;
  };
in
lib.mkIf (host == "desktop") {
  boot.supportedFilesystems = [ "nfs" ];

  fileSystems.${libraryMount} = {
    device = "${piAddress}:${piStackDir}/immich/library";
    fsType = "nfs";
    options = [
      "vers=4.2"
      "noatime"
      "rsize=1048576"
      "wsize=1048576"
      "noauto"
      "x-systemd.automount"
      "x-systemd.idle-timeout=600"
      "x-systemd.mount-timeout=15"
      "_netdev"
    ];
  };

  environment.systemPackages = [ immich-offload ];
}
