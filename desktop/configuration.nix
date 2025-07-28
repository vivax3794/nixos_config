{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../visual/configuration.nix
  ];

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
  console.keyMap = "us";

services.getty.autologinUser = "viv";

}
