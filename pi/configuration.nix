{ config, pkgs, ... }:

{
  imports = [
    "${pkgs.path}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
    ./hardware-configuration.nix
    ../base/configuration.nix
  ];

    boot.loader.grub.enable = false;
boot.loader.generic-extlinux-compatible.enable = true;

  nix.distributedBuilds = true;
  nix.settings.builders-use-substitutes = true;

  nix.buildMachines = [
    {
      hostName = "10.0.0.10";
      sshUser = "viv";
      sshKey = "/home/viv/.ssh/desktop";
      system = pkgs.stdenv.hostPlatform.system;
      supportedFeatures = [
        "nixos-test"
        "big-parallel"
        "kvm"
      ];
    }
  ];
}
