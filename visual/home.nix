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
    ../base/home.nix
    inputs.zen-browser.homeModules.twilight-official
  ];

  programs.kitty = {
    enable = true;
    shellIntegration.enableFishIntegration = true;

    font.package = pkgs.nerd-fonts.fira-code;
    font.name = "Fira Code Nerdfont";
    settings = {
      background_opacity = 0.8;
      background_blur = 0;
      placement_strategy = "top-left";
    };
    themeFile = "tokyo_night_night";
  };
  programs.zen-browser.enable = true;

  services.mako.enable = true;
  programs.waybar = {
    enable = true;
    settings = import ./waybar.nix {
      host = host;
      lib = pkgs.lib;
    };
    style = ../dotfiles/waybar.css;
  };

  programs.tofi = {
    enable = true;
    settings = {
      text-cursor = true;
      font = "Fira Code Nerdfont";
      font-size = 24;
      prompt-color = "#FF00FF";
      num-results = 5;
      result-spacing = 25;
      width = "100%";
      height = "100%";
      background-color = "#000C";
      outline-width = 0;
      border-width = 0;
      padding-top = "15%";
      padding-bottom = 8;
      padding-left = "35%";
      padding-right = 8;
      drun-launch = true;
    };
  };

  home.file.".config/niri/config.kdl".text = import ./niri.nix {
    host = host;
    lib = lib;
  };
}
