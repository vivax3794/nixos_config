{
  config,
  pkgs,
  host,
  lib,
  ...
}:

{
  imports = [ ../cachix.nix ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

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
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE8SpcFB+oGN5v5EuDdkJqE6SQp/BmUYUyn9bTnPL1/p viv" # laptop
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHEpHoI3fLFk1GUuOduAt+bmH6FKTokFKmWmA9DQRiPa viv" # desktop
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB7cFETPGBUPwKdsv/klwUObatmfzzQ6NJWfotytK/ul viv" # Pi
    ];
  };
  programs.fish.enable = true;
  #   programs.ssh = {
  #     extraConfig = "
  # 	Host desktop
  # 	    Hostname 10.0.0.10
  # 	    Port 3794
  # 	    User viv
  # 	    IdentitiesOnly yes
  # 	    IdentifiyFile /home/viv/.ssh/desktop
  # 	Host pi
  # 	    Hostname 10.0.0.11
  # 	    Port 3794
  # 	    User viv
  # 	    IdentitiesOnly yes
  # 	    IdentifiyFile /home/viv/.ssh/pi
  # ";
  #   };

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
      passwordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = [ "viv" ];
    };
  };
  services.fail2ban.enable = true;

  nix.settings.auto-optimise-store = true;
}
