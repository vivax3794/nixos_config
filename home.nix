{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    inputs.nixvim.homeModules.nixvim
    inputs.zen-browser.homeModules.twilight-official
  ];

  home.username = "viv";
  home.homeDirectory = "/home/viv";

  home.packages = with pkgs; [
    fastfetch
    nixfmt-tree
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
  programs.fastfetch.enable = true;

  services.mako.enable = true;
  programs.swaylock.enable = true;
  programs.waybar = {
    enable = true;
    settings = import ./waybar.nix;
    style = ./dotfiles/waybar.css;
  };
  services.swww.enable = true; # Wallpaper

  home.file.".config/niri/config.kdl".source = ./dotfiles/niri.kdl;

  home.stateVersion = "25.05";
}
