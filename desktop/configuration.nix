{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../visual/configuration.nix
  ];

  boot.initrd.luks.devices."luks-f02fa872-7976-4f55-85ce-4ce94c98f43d".device =
    "/dev/disk/by-uuid/f02fa872-7976-4f55-85ce-4ce94c98f43d";

  services.xserver.xkb = {
    layout = "en";
    variant = "";
  };
  console.keyMap = "en";

}
