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
    inputs.zen-browser.homeModules.twilight
  ];

  programs.niri.settings = import ./niri.nix {
    host = host;
    lib = lib;
    pkgs = pkgs;
  };
  services.swww.enable = true;

  home.packages = with pkgs; [
    graphite-cursors
    mission-center
    remmina
    obsidian
    nautilus
    keymapp
    inkscape
    kdePackages.kdenlive
    cura-appimage
    claude-code

    wineWowPackages.stable
    winetricks

    jetbrains.idea-community

    # inputs.serpentine.packages.${system}.default
  ];

  programs.kitty = {
    enable = true;
    shellIntegration.enableFishIntegration = true;

    font.package = pkgs.nerd-fonts.fira-code;
    font.name = "Fira Code Nerdfont";
    settings = {
      font_size = 14;
      background_opacity = 0.8;
      background_blur = 0;
      placement_strategy = "top-left";
    };
    themeFile = "tokyo_night_night";
    keybindings = {
      "ctrl+t" = "launch --cwd=current --type=os-window";
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

  programs.vesktop = {
    enable = true;

    settings = {
      transperencyOption = "acrylic";
      audio.onlySpeakers = true;
    };

    vencord.settings = {
      autoUpdate = false;
      autoUpdateNotification = false;
      plugins = {
        petpet.enabled = true;
        SilentTyping = {
          enabled = true;
          showIcon = true;
          contextMenu = false;
        };
        AnonymiseFileNames.enabled = true;
        BetterGifPicker.enabled = true;
        ClearURLs.enabled = true;
        MentionAvatars.enabled = true;
        BetterFolders.enabled = true;
      };
    };
  };

  programs.chromium.enable = true;

  home.activation = {
    # https://github.com/philj56/tofi/issues/115#issuecomment-1701748297
    regenerateTofiCache = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      tofi_cache=${config.xdg.cacheHome}/tofi-drun
      [[ -f "$tofi_cache" ]] && rm "$tofi_cache"
    '';
  };
}
