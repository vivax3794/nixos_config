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
    ./features/niri-templates.nix
    ./features/command-notify.nix
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
      proton-vpn
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
    settings = import ./dotfiles/fastfetch.nix;
  };

  # Fish shell
  programs.fish = {
    enable = true;
    preferAbbrs = true;
    shellInit = ''
      set fish_greeting
      abbr --add nsp --set-cursor 'nix-shell -p % --run fish'
    ''
    + builtins.readFile (
      builtins.fetchurl {
        url = "https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/fish/tokyonight_night.fish";
        sha256 = "030zs3fvznn83128ply1wk739p8ywfndnyx45jxnlmmqvm9s6r6r";
      }
    );
    shellAbbrs = {
      cat = "bat";
      cd = "z";
      ls = "eza -lh --total-size";
      grep = "rg";
    };
    functions.nsr = "nix-shell -p $argv[1] --run $argv[1]";
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
  programs.bat = {
    enable = true;
    config.theme = "tokyonight_night";
  };
  programs.atuin = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      style = "compact";
      inline_height = 20;
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
  programs.nixvim = import ./dotfiles/nvim.nix {
    inherit
      host
      lib
      inputs
      pkgs
      ;
  };

  # Git
  programs.git.enable = true;
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      line-numbers = true;
    };
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
        paginate = "auto";
        pager = "delta";
        diff-formatter = ":git";
        diff-editor = [
          "nvim"
          "-c"
          "DiffEditor $left $right $output"
        ];
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
  programs.niri.settings = import ./dotfiles/niri.nix {
    inherit
      host
      inputs
      lib
      pkgs
      ;
  };
  services.awww.enable = true;

  # Terminal
  programs.kitty = {
    enable = true;
    shellIntegration.enableFishIntegration = true;
    font.package = pkgs.nerd-fonts.fira-code;
    font.name = theme.font;
    settings = {
      font_size = 12;
      background_opacity = 0.8;
      background_blur = 0;
      placement_strategy = "top-left";
    };
    themeFile = "tokyo_night_night";
  };

  # Browsers
  programs.zen-browser = {
    enable = true;
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
  programs.waybar = import ./dotfiles/waybar.nix { inherit host lib; };

  # Launcher
  programs.anyrun = import ./dotfiles/anyrun.nix { inherit pkgs; };

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
    settings =
      let
        c = lib.mapAttrs (_: lib.removePrefix "#") theme.colors;
      in
      {
        font = theme.font;
        font-size = 24;

        screenshot = true;
        effect-blur = "20x3";
        effect-vignette = "0.8:0.8";
        effect-greyscale = true;

        clock = true;
        timestr = "%H:%M";
        datestr = "%a, %b %d";

        inside-color = "${c.background}00";
        ring-color = c.blue;
        key-hl-color = c.green;
        bs-hl-color = c.red;
        text-color = c.foreground;
        line-color = "00000000";
        separator-color = "00000000";
        inside-clear-color = "${c.background}00";
        ring-clear-color = c.yellow;
        text-clear-color = c.foreground;
        inside-ver-color = "${c.background}00";
        ring-ver-color = c.purple;
        text-ver-color = c.foreground;
        inside-wrong-color = "${c.background}00";
        ring-wrong-color = c.red;
        text-wrong-color = c.red;

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

  # Claude Code user-level config
  home.file.".claude/CLAUDE.md".source = ./dotfiles/claude-global.md;
  home.file.".claude/commands".source = ./dotfiles/claude_commands;
  home.file.".claude/settings.json".text = ''
    {
      "showThinkingSummaries": true,
      "effortLevel": "high"
    }
  '';

  fonts.fontconfig.enable = true;

  home.stateVersion = "25.05";
}
