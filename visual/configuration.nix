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

  environment.systemPackages = with pkgs; [
    xdg-desktop-portal-gtk
    pavucontrol
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

  nixpkgs.overlays = [ inputs.niri.overlays.niri ];
  programs.niri = {
    enable = true;
    package = pkgs.niri-unstable;
  };

  system.stateVersion = "25.05";
}
