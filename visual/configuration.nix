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
  ];
  programs.niri.enable = true;

  system.stateVersion = "25.05";
}
