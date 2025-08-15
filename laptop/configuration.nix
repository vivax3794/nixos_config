{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../visual/configuration.nix
  ];

  security.pam.services.swaylock = { };

  boot.initrd.luks.devices."luks-f02fa872-7976-4f55-85ce-4ce94c98f43d".device =
    "/dev/disk/by-uuid/f02fa872-7976-4f55-85ce-4ce94c98f43d";

  services.xserver.xkb = {
    layout = "no";
    variant = "";
  };
  console.keyMap = "no";

  services.cloudflare-warp = {
    enable = true;
  };

  nix.distributedBuilds = true;
  nix.settings.builders-use-substitutes = true;

  nix.buildMachines = [
    {
      hostName = "10.0.0.10";
      sshUser = "viv";
      sshKey = "/home/viv/.ssh/desktop";
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      supportedFeatures = [
        "nixos-test"
        "big-parallel"
        "kvm"
      ];
    }
  ];
}
