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
    figma-linux
  ];

  programs.swaylock.enable = true;
}
