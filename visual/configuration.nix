{
  config,
  pkgs,
  host,
  inputs,
  ...
}:

{
  imports = [
    ../base/configuration.nix
    inputs.niri.nixosModules.niri
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  environment.systemPackages = with pkgs; [
    xdg-desktop-portal-gtk
    pavucontrol
  ];

  hardware.keyboard.zsa.enable = true;

  networking.networkmanager.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    nssmdns6 = true;
    openFirewall = true;
  };
  # networking.firewall.enable = false;
  networking.firewall.allowedTCPPorts = [ 5000 ];
  networking.firewall.allowedUDPPorts = [
    5353
    1900
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    protontricks.enable = true;
  };
  programs.appimage.enable = true;
  programs.appimage.binfmt = true;

  hardware.bluetooth.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

  };
  users.users.viv.extraGroups = [ "audio" ];

  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
  };

  programs.niri = {
    enable = true;
    package = pkgs.niri-unstable;
  };

  system.stateVersion = "25.05";
}
