{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [ ../visual/home.nix ];

  home.packages = with pkgs; [
    nvtopPackages.nvidia
    lm_sensors
    rpi-imager
    openscad
    dolphin-emu
    qbittorrent
  ];

  programs.obs-studio.enable = true;
}
