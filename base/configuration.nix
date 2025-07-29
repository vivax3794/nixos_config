{
  config,
  pkgs,
  host,
  ...
}:

{
  imports = [ ../cachix.nix ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = host;
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Oslo";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users.viv = {
    isNormalUser = true;
    description = "vivax";
    extraGroups = [
      "networkmanager"
      "wheel" # Sudo
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
