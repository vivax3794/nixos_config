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
    font.package = pkgs.nerd-fonts.fira-code;
    font.name = "Fira Code Nerdfont";
    settings = {
      background_opacity = 0.6;
      background_blur = 0;
      placement_strategy = "top-left";
    };
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

  home.file.".config/niri/config.kdl".text =
    builtins.readFile ../dotfiles/niri.kdl
    + lib.optionalString (host == "laptop") ''
      spawn-at-startup "swww" "img" "/etc/nixos/wallpaper/laptop.jpeg"

      output "eDP-1" {
          mode "1920x1080@60"
          scale 1.25
          transform "normal"
          position x=0 y=0
      }
    '';

}
