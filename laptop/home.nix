{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [ ../visual/home.nix ];

  home.packages = with pkgs; [
    geteduroam
  ];

  programs.swaylock.enable = true;
  services.swww.enable = true;
}
