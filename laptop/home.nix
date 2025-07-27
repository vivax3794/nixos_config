{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [ ../base/home.nix ];

  programs.swaylock.enable = true;
  services.swww.enable = true; # Wallpaper
}
