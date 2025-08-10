{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../base/configuration.nix
  ];

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  nix.distributedBuilds = true;
  nix.settings.builders-use-substitutes = true;

  nix.settings.max-jobs = 0;
  nix.settings.eval-cache = true;
  nix.buildMachines = [
    {
      hostName = "10.0.0.10";
      sshUser = "viv";
      sshKey = "/home/viv/.ssh/desktop";
      systems = ["x86_64-linux" "aarch64-linux"];
      supportedFeatures = [
        "nixos-test"
        "big-parallel"
        "kvm"
      ];
    }
  ];
}
