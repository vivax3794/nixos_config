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
  theme = import ./theme.nix;
in
{
  imports = [
    inputs.nixvim.homeModules.nixvim
    inputs.zen-browser.homeModules.twilight
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
    ./features/smart-terminal.nix
  ];

  home.username = "viv";
  home.homeDirectory = "/home/viv";

  # Cursor (works across Wayland + XWayland)
  home.pointerCursor = {
    package = pkgs.graphite-cursors;
    name = "graphite-dark-nord";
    size = 24;
    gtk.enable = true;
  };

  home.packages =
    with pkgs;
    [
      # Base packages
      cachix
      hyfetch
      nixfmt-tree
      killall
      eza
      ripgrep
      unzip
      noto-fonts

      # Visual/GUI packages

      mission-center
      obsidian
      nautilus
      keymapp
      inkscape
      cura-appimage
      claude-code
      libresprite
      wineWow64Packages.stable
      winetricks
      protonvpn-gui
      openscad
    ]
    ++ lib.optionals isLaptop [
      geteduroam

      # JAVA BS
      maven
      openjdk25
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
    ''
    + builtins.readFile (
      builtins.fetchurl {
        url = "https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/fish/tokyonight_night.fish";
        sha256 = "030zs3fvznn83128ply1wk739p8ywfndnyx45jxnlmmqvm9s6r6r";
      }
    );
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
      format = "$directory$custom$cmd_duration\n$character";
      direnv.disabled = false;
      custom.jj = {
        when = "${
          inputs.jj-starship.packages.${pkgs.stdenv.hostPlatform.system}.default
        }/bin/jj-starship detect";
        shell = [
          "${inputs.jj-starship.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/jj-starship"
        ];
        format = "$output ";
      };
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
    inherit
      host
      lib
      inputs
      pkgs
      ;
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
    font.name = theme.font;
    settings = {
      font_size = 14;
      background_opacity = 0.8;
      background_blur = 0;
      placement_strategy = "top-left";
    };
    themeFile = "tokyo_night_night";
  };

  # Browsers
  programs.zen-browser = {
    enable = true;
    suppressXdgMigrationWarning = true;
  };
  programs.chromium.enable = true;

  # Notifications
  services.mako = {
    enable = true;
    settings = {
      font = "${theme.font} 11";
      background-color = theme.colors.background;
      text-color = theme.colors.foreground;
      border-color = theme.colors.blue;
      border-size = 2;
      border-radius = 12;
      default-timeout = 5000;
    };
  };

  # Battery notifications
  services.batsignal = lib.mkIf isLaptop {
    enable = true;
    extraArgs = [
      "-w"
      "30"
      "-c"
      "15"
      "-d"
      "5"
    ];
  };

  # Waybar
  programs.waybar = {
    enable = true;
    settings = import ./waybar.nix { inherit host lib; };
    style = ./dotfiles/waybar.css;
  };

  # Launcher
  programs.anyrun = {
    enable = true;
    config = {
      x.fraction = 0.5;
      y.fraction = 0.3;
      width.absolute = 600;
      hideIcons = false;
      closeOnClick = true;
      showResultsImmediately = true;
      maxEntries = 7;
      hidePluginInfo = true;
      layer = "overlay";
      plugins = map (p: "${pkgs.anyrun}/lib/${p}") [
        "libapplications.so"
        "librink.so"
        "libshell.so"
        "libwebsearch.so"
        "libniri_focus.so"
        "libnix_run.so"
      ];
    };
    extraConfigFiles."nix-run.ron".text = ''
      Config(
        prefix: ":nr ",
        max_entries: 5,
        allow_unfree: true,
      )
    '';
    extraConfigFiles."websearch.ron".text = ''
      Config(
        prefix: "?",
        engines: [DuckDuckGo],
      )
    '';
    extraCss = with theme.colors; ''
      * {
        font-family: "${theme.font}";
        font-size: 15px;
      }

      @keyframes slide-in {
        from {
          opacity: 0;
          margin-top: -20px;
        }
        to {
          opacity: 1;
          margin-top: 0;
        }
      }

      window {
        background: transparent;
      }

      .main {
        background-color: alpha(${background}, 0.88);
        border: 2px solid alpha(${blue}, 0.5);
        border-radius: 16px;
        padding: 12px;
        animation: slide-in 250ms ease-out;
      }

      entry {
        background-color: alpha(${selection}, 0.6);
        border: 1px solid alpha(${comment}, 0.3);
        border-radius: 10px;
        padding: 8px 16px;
        margin-bottom: 8px;
        min-height: 32px;
        caret-color: ${purple};
        color: ${foreground};
      }

      text {
        color: ${foreground};
      }

      entry:focus {
        border-color: alpha(${blue}, 0.6);
      }

      .matches {
        background-color: transparent;
      }

      list.plugin {
        background-color: transparent;
      }

      .match {
        background: transparent;
        padding: 4px 8px;
        margin: 2px 4px;
        border-radius: 8px;
        transition: all 200ms ease;
      }

      .match:hover {
        background-color: alpha(${selection}, 0.4);
      }

      .match:selected {
        background-color: alpha(${blue}, 0.2);
        border: 1px solid alpha(${blue}, 0.3);
      }

      .match .title {
        color: ${foreground};
        font-weight: 500;
      }

      .match .description {
        color: ${comment};
        font-size: 13px;
      }

      .match:selected .title {
        color: ${cyan};
      }

      .plugin {
        padding: 2px;
      }
    '';
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
  programs.swaylock = lib.mkIf isLaptop {
    enable = true;
    package = pkgs.swaylock-effects;
    settings = {
      font = theme.font;
      font-size = 24;

      #image = "${./wallpapers/laptop.jpeg}";
      screenshot = true;
      effect-blur = "20x3";
      effect-vignette = "0.8:0.8";
      effect-greyscale = true;

      clock = true;
      timestr = "%H:%M";
      datestr = "%a, %b %d";

      inside-color = "1a1b2600";
      ring-color = "7aa2f7";
      key-hl-color = "9ece6a";
      bs-hl-color = "f7768e";
      text-color = "c0caf5";
      line-color = "00000000";
      separator-color = "00000000";
      inside-clear-color = "1a1b2600";
      ring-clear-color = "e0af68";
      text-clear-color = "c0caf5";
      inside-ver-color = "1a1b2600";
      ring-ver-color = "9d7cd8";
      text-ver-color = "c0caf5";
      inside-wrong-color = "1a1b2600";
      ring-wrong-color = "f7768e";
      text-wrong-color = "f7768e";

      indicator = true;
      indicator-radius = 100;
      indicator-thickness = 7;
      ignore-empty-password = true;
      show-failed-attempts = true;
    };
  };

  programs.obs-studio.enable = true;

  home.sessionVariables = {
    XDG_DATA_DIRS = "$XDG_DATA_DIRS:$HOME/.local/share/flatpak/exports/share";
  };

  nix.settings.trusted-users = [
    "viv"
    "@wheel"
  ];
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  fonts.fontconfig.enable = true;

  home.stateVersion = "25.05";
}
