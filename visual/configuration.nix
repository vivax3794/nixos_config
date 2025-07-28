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
  ];

  environment.systemPackages = with pkgs; [
    xdg-desktop-portal-gtk
    xwayland-satellite
  ];
  programs.niri.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    protontricks.enable = true;
  };
  programs.appimage.enable = true;
  programs.appimage.binfmt = true;

  system.stateVersion = "25.05";
}
