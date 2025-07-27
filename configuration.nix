{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  security.pam.services.swaylock = { };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices."luks-f02fa872-7976-4f55-85ce-4ce94c98f43d".device =
    "/dev/disk/by-uuid/f02fa872-7976-4f55-85ce-4ce94c98f43d";

  networking.hostName = "laptop";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Oslo";
  i18n.defaultLocale = "en_US.UTF-8";
  services.xserver.xkb = {
    layout = "no";
    variant = "";
  };
  console.keyMap = "no";

  users.users.viv = {
    isNormalUser = true;
    description = "vivax";
    extraGroups = [
      "networkmanager"
      "wheel" # Sudo
    ];
    packages = with pkgs; [ ];
  };

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  environment.systemPackages = with pkgs; [ xdg-desktop-portal-gtk ];
  programs.niri.enable = true;

  system.stateVersion = "25.05";

}
