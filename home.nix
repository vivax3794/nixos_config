{
  config,
  pkgs,
  inputs,
  host,
  lib,
  ...
}:

let
  isDesktop = host == "desktop";
  isLaptop = host == "laptop";
in
{
  imports = [
    inputs.nixvim.homeModules.nixvim
    inputs.zen-browser.homeModules.twilight
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
  ];

  home.username = "viv";
  home.homeDirectory = "/home/viv";

  home.packages = with pkgs; [
    # Base packages
    cachix
    hyfetch
    nixfmt-tree
    killall
    eza
    ripgrep
    unzip

    # Visual/GUI packages
    graphite-cursors
    mission-center
    obsidian
    nautilus
    keymapp
    inkscape
    cura-appimage
    claude-code
    libresprite
    wineWowPackages.stable
    winetricks
    protonvpn-gui
    openscad
  ]
  ++ lib.optionals isLaptop [
    geteduroam
  ]
  ++ lib.optionals isDesktop [
    nvtopPackages.nvidia
    lm_sensors
    rpi-imager
    dolphin-emu
    qbittorrent
  ];

  # Fastfetch
  programs.fastfetch = {
    enable = true;
    settings = import ./fastfetch.nix;
  };

  # Fish shell
  programs.fish = {
    enable = true;
    preferAbbrs = true;
    shellInit = ''
      set fish_greeting
    '' + lib.readFile ./dotfiles/colors.fish;
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
      format = "$directory$cmd_duration\n$character";
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

  # Neovim
  programs.nixvim = import ./nvim.nix {
    inherit host lib inputs pkgs;
  };

  # Git
  programs.git.enable = true;
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

  # Niri window manager
  programs.niri.settings = import ./niri.nix {
    inherit host lib pkgs;
  };
  services.swww.enable = true;

  # Flatpak
  services.flatpak = {
    enable = true;
    packages = [ "net.waterfox.waterfox" ];
    update.onActivation = true;
  };

  # Terminal
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

  # Browsers
  programs.zen-browser.enable = true;
  programs.chromium.enable = true;

  # Notifications
  services.mako.enable = true;

  # Waybar
  programs.waybar = {
    enable = true;
    settings = import ./waybar.nix { inherit host lib; };
    style = ./dotfiles/waybar.css;
  };

  # Launcher
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

  # Discord
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

  # Laptop-specific
  programs.swaylock.enable = lib.mkIf isLaptop true;

  # Desktop-specific
  programs.obs-studio.enable = true;

  home.sessionVariables = {
    XDG_DATA_DIRS = "$XDG_DATA_DIRS:$HOME/.local/share/flatpak/exports/share";
  };
  home.activation = {
    regenerateTofiCache = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      tofi_cache=${config.xdg.cacheHome}/tofi-drun
      [[ -f "$tofi_cache" ]] && rm "$tofi_cache"
    '';
  };

  nix.settings.trusted-users = [ "viv" "@wheel" ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  home.stateVersion = "25.05";
}
