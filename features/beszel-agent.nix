{
  lib,
  host,
  ...
}:
let
  port = 45876;
in
lib.mkIf (host == "desktop") {
  services.beszel.agent = {
    enable = true;
    environment = {
      LISTEN = toString port;
      KEY = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOVO6bUgaG4b+V4g1XMUbJQNFGqMx2TmILN1jkkFGLyv";
      GPU_COLLECTOR = [ "amd_sysfs" ];
    };
    smartmon = {
      enable = true;
      deviceAllow = [ "/dev/nvme0n1" ];
    };
  };
}
