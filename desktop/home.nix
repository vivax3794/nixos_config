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
    mkchromecast
    liquidctl
    lm_sensors
  ];

  programs.chromium.enable = true;
}
