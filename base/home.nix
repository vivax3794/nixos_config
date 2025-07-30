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
    killall
    just
  ];

  programs.fish = {
    enable = true;
    preferAbbrs = true;
    shellInit = ''
      set fish_greeting
    '';
  };
  home.shell.enableFishIntegration = true;
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
  };
  programs.nixvim = import ./nvim.nix { host = host; };
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
      theme_background = false;
      update_ms = 100;
      swap_disk = false;
    };
  };

  home.stateVersion = "25.05";
}
