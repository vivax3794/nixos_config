{
  config,
  pkgs,
  inputs,
  host,
  lib,
  ...
}:

{
  imports = [
    inputs.nixvim.homeModules.nixvim
  ];

  home.username = "viv";
  home.homeDirectory = "/home/viv";

  home.packages = with pkgs; [
    cachix
    hyfetch
    nixfmt-tree
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
  };

  programs.git = {
    enable = true;
  };
  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        email = "vivax3794@protonmail.com";
        name = "Viv";
      };
    };
  };
  programs.gh.enable = true;

  programs.btop = {
    enable = true;
    settings = {
      color_theme = "tokyo-night";
      update_ms = 100;
      swap_disk = false;
    };
  };

  home.stateVersion = "25.05";
}
