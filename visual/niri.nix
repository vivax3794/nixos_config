{
  host,
  lib,
  pkgs,
}:

{
  input = {
    keyboard = {
      xkb = lib.mkIf (host == "laptop") {
        layout = "no";
        options = "caps:escape,ctrl:swap_rwin_rctl";
      };
      numlock = true;
    };

    touchpad = {
      tap = true;
      natural-scroll = true;
    };

    warp-mouse-to-focus.enable = true;
  };

  cursor = {
    theme = "graphite-dark-nord";
  };

  layout = {
    gaps = 8;
    center-focused-column = "on-overflow";
    default-column-width = {
      proportion = 0.5;
    };
    focus-ring = {
      width = 4;
      active.color = "#7aa2f7";
      inactive.color = "#505050";
    };
    struts = {
      left = 16;
      right = 16;
      top = 0;
      bottom = 4;
    };

    preset-column-widths = [
      { proportion = 0.25; }
      { proportion = 0.33333; }
      { proportion = 0.5; }
      { proportion = 0.66666; }
    ];

    tab-indicator = {
      position = "top";
      place-within-column = true;
      width = 8;
      gap = 8;
      corner-radius = 20;
    };
  };

  environment = {
    DISPLAY = ":0";
  }
  // lib.optionalAttrs (host == "desktop") {
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBARY_NAME = "nvidia";
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
  };

  spawn-at-startup = [
    { command = [ (lib.getExe pkgs.waybar) ]; }
    { command = [ (lib.getExe pkgs.xwayland-satellite) ]; }
  ]
  ++ lib.optionals (host == "laptop") [
    {
      command = [
        (lib.getExe pkgs.swww)
        "img"
        "/etc/nixos/wallpapers/laptop.jpeg"
      ];
    }
  ]
  ++ lib.optionals (host == "desktop") [
    (
      let
        wallpaperScript = pkgs.writeShellScript "wallpaper-cycle" ''
          MPVPAPER_PID1=""
          MPVPAPER_PID2=""

          start_mpvpaper() {
              ${pkgs.mpvpaper}/bin/mpvpaper \
                  -o "no-audio loop hwdec=auto vf=crop=w=3440:h=1440 gpu-api=vulkan" \
                  --auto-pause DP-3 ${../wallpapers/wide.mp4} &
              MPVPAPER_PID1=$!
              
              ${pkgs.mpvpaper}/bin/mpvpaper \
                  -o "no-audio loop hwdec=auto vf=crop=w=1080:h=1920 gpu-api=vulkan" \
                  --auto-pause HDMI-A-3 ${../wallpapers/vertical.mp4} &
              MPVPAPER_PID2=$!
          }

          kill_mpvpaper() {
              if [[ -n "$MPVPAPER_PID1" ]] && kill -0 "$MPVPAPER_PID1" 2>/dev/null; then
                  kill -9 "$MPVPAPER_PID1"
              fi
              
              if [[ -n "$MPVPAPER_PID2" ]] && kill -0 "$MPVPAPER_PID2" 2>/dev/null; then
                  kill -9 "$MPVPAPER_PID2"
              fi
          }

          while true; do
              start_mpvpaper
              sleep 1800
              kill_mpvpaper
              sleep 1
          done
        '';
      in
      {
        command = [ "${wallpaperScript}" ];
      }
    )
  ];

  prefer-no-csd = true;
  screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

  animations = { };

  window-rules = [
    {
      matches = [
        {
          app-id = "zen-browser$";
          title = "^Picture-in-Picture$";
        }
      ];
      open-floating = true;
    }
    {
      geometry-corner-radius =
        let
          radius = 12.0;
        in
        {
          bottom-left = radius;
          bottom-right = radius;
          top-left = radius;
          top-right = radius;
        };
      clip-to-geometry = true;
      draw-border-with-background = false;
    }
  ];

  binds = {
    "Mod+Shift+W".action.show-hotkey-overlay = { };
    "Mod+T".action.spawn = "kitty";
    "Mod+R".action.spawn = "tofi-drun";

    "Mod+O" = {
      action.toggle-overview = { };
      repeat = false;
    };
    "Mod+Q".action.close-window = { };

    # Focus bindings
    "Mod+H".action.focus-column-or-monitor-left = { };
    "Mod+J".action.focus-window-or-workspace-down = { };
    "Mod+K".action.focus-window-or-workspace-up = { };
    "Mod+L".action.focus-column-or-monitor-right = { };
    "Mod+Shift+H".action.focus-monitor-left = { };
    "Mod+Shift+L".action.focus-monitor-right = { };

    # Move bindings
    "Mod+Ctrl+H".action.move-column-left-or-to-monitor-left = { };
    "Mod+Ctrl+J".action.move-window-down-or-to-workspace-down = { };
    "Mod+Ctrl+K".action.move-window-up-or-to-workspace-up = { };
    "Mod+Ctrl+L".action.move-column-right-or-to-monitor-right = { };
    "Mod+Ctrl+Shift+H".action.move-column-to-monitor-left = { };
    "Mod+Ctrl+Shift+L".action.move-column-to-monitor-right = { };

    # Column navigation
    "Mod+Home".action.focus-column-first = { };
    "Mod+End".action.focus-column-last = { };
    "Mod+Ctrl+Home".action.move-column-to-first = { };
    "Mod+Ctrl+End".action.move-column-to-last = { };

    # Workspace navigation
    "Mod+U".action.focus-workspace-down = { };
    "Mod+I".action.focus-workspace-up = { };
    "Mod+Ctrl+Page_Down".action.move-column-to-workspace-down = { };
    "Mod+Ctrl+Page_Up".action.move-column-to-workspace-up = { };
    "Mod+Ctrl+U".action.move-column-to-workspace-down = { };
    "Mod+Ctrl+I".action.move-column-to-workspace-up = { };

    "Mod+Shift+Page_Down".action.move-workspace-down = { };
    "Mod+Shift+Page_Up".action.move-workspace-up = { };
    "Mod+Shift+U".action.move-workspace-down = { };
    "Mod+Shift+I".action.move-workspace-up = { };

    # Mouse wheel bindings
    "Mod+WheelScrollDown" = {
      action.focus-workspace-down = { };
      cooldown-ms = 150;
    };
    "Mod+WheelScrollUp" = {
      action.focus-workspace-up = { };
      cooldown-ms = 150;
    };
    "Mod+Ctrl+WheelScrollDown" = {
      action.move-column-to-workspace-down = { };
      cooldown-ms = 150;
    };
    "Mod+Ctrl+WheelScrollUp" = {
      action.move-column-to-workspace-up = { };
      cooldown-ms = 150;
    };

    "Mod+WheelScrollRight".action.focus-column-right = { };
    "Mod+WheelScrollLeft".action.focus-column-left = { };
    "Mod+Ctrl+WheelScrollRight".action.move-column-right = { };
    "Mod+Ctrl+WheelScrollLeft".action.move-column-left = { };

    "Mod+Shift+WheelScrollDown".action.focus-column-right = { };
    "Mod+Shift+WheelScrollUp".action.focus-column-left = { };
    "Mod+Ctrl+Shift+WheelScrollDown".action.move-column-right = { };
    "Mod+Ctrl+Shift+WheelScrollUp".action.move-column-left = { };

    # Workspace numbers
    "Mod+1".action.focus-workspace = 1;
    "Mod+2".action.focus-workspace = 2;
    "Mod+3".action.focus-workspace = 3;
    "Mod+4".action.focus-workspace = 4;
    "Mod+5".action.focus-workspace = 5;
    "Mod+6".action.focus-workspace = 6;
    "Mod+7".action.focus-workspace = 7;
    "Mod+8".action.focus-workspace = 8;
    "Mod+9".action.focus-workspace = 9;

    "Mod+Ctrl+1".action.move-column-to-workspace = 1;
    "Mod+Ctrl+2".action.move-column-to-workspace = 2;
    "Mod+Ctrl+3".action.move-column-to-workspace = 3;
    "Mod+Ctrl+4".action.move-column-to-workspace = 4;
    "Mod+Ctrl+5".action.move-column-to-workspace = 5;
    "Mod+Ctrl+6".action.move-column-to-workspace = 6;
    "Mod+Ctrl+7".action.move-column-to-workspace = 7;
    "Mod+Ctrl+8".action.move-column-to-workspace = 8;
    "Mod+Ctrl+9".action.move-column-to-workspace = 9;

    # Window management
    "Mod+BracketLeft".action.consume-or-expel-window-left = { };
    "Mod+BracketRight".action.consume-or-expel-window-right = { };

    "Mod+Comma".action.consume-window-into-column = { };
    "Mod+Period".action.expel-window-from-column = { };

    "Mod+S".action.switch-preset-column-width = { };
    "Mod+F".action.maximize-column = { };
    "Mod+Shift+F".action.fullscreen-window = { };
    "Mod+Ctrl+F".action.toggle-windowed-fullscreen = { };

    "Mod+C".action.center-column = { };
    "Mod+Ctrl+C".action.center-visible-columns = { };

    "Mod+Minus".action.set-column-width = "-10%";
    "Mod+Equal".action.set-column-width = "+10%";

    "Mod+Shift+Minus".action.set-window-height = "-10%";
    "Mod+Shift+Equal".action.set-window-height = "+10%";

    "Mod+V".action.toggle-window-floating = { };
    "Mod+Shift+V".action.switch-focus-between-floating-and-tiling = { };

    "Mod+W".action.toggle-column-tabbed-display = { };
    "Mod+Shift+S".action.screenshot = { };
    "Ctrl+Print".action.screenshot-screen = { };
    "Alt+Print".action.screenshot-window = { };

    "Mod+Escape" = {
      action.toggle-keyboard-shortcuts-inhibit = { };
      allow-inhibiting = false;
    };
    "Mod+Shift+E".action.quit = { };
    "Ctrl+Alt+Delete".action.quit = { };
    "Mod+Shift+P".action.power-off-monitors = { };
  }
  // lib.optionalAttrs (host == "laptop") {
    "Mod+Ctrl+W".action.spawn = [
      "swaylock"
      "--color"
      "000000"
    ];
  }
  // (
    let
      smartTerminal = pkgs.writeShellScript "smart-terminal" ''
        if ${pkgs.niri}/bin/niri msg focused-window | ${pkgs.ripgrep}/bin/rg ".*kitty.*" >/dev/null; then
          ${pkgs.wtype}/bin/wtype -M ctrl t -m ctrl
        else
          exec ${pkgs.kitty}/bin/kitty
        fi
      '';
    in
    {
      "Mod+T".action.spawn = [ "${smartTerminal}" ];
    }
  )

  ;

  outputs = lib.mkMerge [
    (lib.mkIf (host == "laptop") {
      "eDP-1" = {
        mode = {
          width = 1920;
          height = 1080;
          refresh = 60.0;
        };
        scale = 1.25;
        position = {
          x = 0;
          y = 0;
        };
      };
    })
    (lib.mkIf (host == "desktop") {
      "DP-3" = {
        mode = {
          width = 3440;
          height = 1440;
          refresh = 100.0;
        };
        scale = 1.0;
        position = {
          x = 1080;
          y = 500;
        };
      };
      "HDMI-A-3" = {
        mode = {
          width = 1920;
          height = 1080;
          refresh = 60.0;
        };
        scale = 1.0;
        transform.rotation = 90;
        position = {
          x = 0;
          y = 0;
        };
      };
    })
  ];
}
