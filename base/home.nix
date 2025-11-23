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
    eza
    ripgrep

    unzip
  ];

  programs.fastfetch = {
    enable = true;
    settings = import ./fastfetch.nix;
  };

  programs.fish = {
    enable = true;
    preferAbbrs = true;
    shellInit = ''
      set fish_greeting
    ''
    + lib.readFile ../dotfiles/colors.fish;

    shellAbbrs = {
      cd = "z";
      ls = "eza -lh --total-size";
      grep = "rg";
    };
  };
  home.shell.enableFishIntegration = true;
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      format = "$directory$cmd_duration
$character";
      direnv.disabled = false;
    };
  };
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.nixvim = import ./nvim.nix {
    host = host;
    lib = lib;
    inputs = inputs;
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
      ui = {
        default-command = "log";
        paginate = "never";
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

  nix.settings.trusted-users = [
    "viv"
    "@wheel"
  ];
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  home.stateVersion = "25.05";
}
