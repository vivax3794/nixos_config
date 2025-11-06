{
  config,
  pkgs,
  host,
  lib,
  ...
}:

{
  imports = [ ../cachix.nix ];

  boot.kernelPackages = pkgs.pkgs.linuxPackages_latest;

  networking.hostName = host;

  time.timeZone = "Europe/Oslo";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users.viv = {
    isNormalUser = true;
    description = "vivax";
    extraGroups = [
      "networkmanager"
      "wheel" # Sudo
      "remotebuilder"
    ];
    shell = pkgs.fish;
    packages = with pkgs; [ ];
  };
  programs.fish.enable = true;

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  system.stateVersion = "25.05";
}
// lib.optionalAttrs (host != "laptop") {
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = true;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = [ "viv" ];
    };
  };
  services.fail2ban.enable = true;

  nix.settings.auto-optimise-store = true;
}
