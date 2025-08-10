{ config, pkgs, ... }:

{
  imports = [
    "${pkgs.path}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
    ../base/configuration.nix
  ];

  nixpkgs.hostPlatform = "aarch64-linux";

  boot = {
    kernelParams = [
      "usb-storage.quirks=174c:55aa:u"
    ];

    loader.timeout = 10;

    initrd.availableKernelModules = [
      "usbhid"
      "usb_storage"
      "uas"
    ];
  };

  # nix.distributedBuilds = true;
  # nix.settings.builders-use-substitutes = true;
  #
  # nix.buildMachines = [
  #   {
  #     hostName = "10.0.0.10";
  #     sshUser = "viv";
  #     sshKey = "/home/viv/.ssh/desktop";
  #     system = pkgs.stdenv.hostPlatform.system;
  #     supportedFeatures = [
  #       "nixos-test"
  #       "big-parallel"
  #       "kvm"
  #     ];
  #   }
  # ];
}
