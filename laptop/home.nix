{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [ ../visual/home.nix ];

  programs.swaylock.enable = true;
  services.swww.enable = true;
}
