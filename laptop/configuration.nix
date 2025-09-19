{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../visual/configuration.nix
  ];

  security.pam.services.swaylock = { };

  boot.initrd.luks.devices."luks-25fa8b36-82c5-45bf-84b1-6dfc46042013".device =
    "/dev/disk/by-uuid/25fa8b36-82c5-45bf-84b1-6dfc46042013";

  services.xserver.xkb = {
    layout = "no";
    variant = "";
  };
  console.keyMap = "no";

  services.cloudflare-warp = {
    enable = true;
  };
}
