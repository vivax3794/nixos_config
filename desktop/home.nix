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
    (import inputs.rpipkgs { inherit system; }).rpi-imager
  ];

  programs.obs-studio.enable = true;
}
