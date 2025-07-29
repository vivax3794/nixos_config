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
  ];

  programs.mpvpaper.enable = true;
  programs.chromium.enable = true;
}
