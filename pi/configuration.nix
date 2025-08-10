{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../base/configuration.nix
  ];

  nixpkgs.hostPlatform = "aarch64-linux";

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  networking.useDHCP = true;

  nix.distributedBuilds = true;
  nix.settings = {
    substituters = [ "https://cache.nixos.org" ];
    trusted-substituters = [ "https://cache.nixos.org" ];
    builders-use-substitutes = true;
    max-jobs = 0;
    eval-cache = true;
  };

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
