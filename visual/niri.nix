{ host, lib }:
''
    input {
        keyboard {
            xkb {
  	      ${
           lib.optionalString (host == "laptop") ''
             layout "no"
             options "caps:escape,ctrl:swap_rwin_rctl"''
         }
            }
            numlock
        }

        touchpad {
            tap
            natural-scroll
        }
        warp-mouse-to-focus
    }

    layout {
        gaps 8
        center-focused-column "on-overflow"
        default-column-width { proportion 0.5; }
        focus-ring {
            width 4
            active-color "#7aa2f7"
            inactive-color "#505050"
        }
        struts {
    	left 16
    	right 16
    	top 0
    	bottom 4
        }
    }

    environment {
    	DISPLAY ":0"
    }

    spawn-at-startup "waybar"
    spawn-at-startup "xwayland-satellite"

    prefer-no-csd
    screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

    animations {}

    window-rule {
        match app-id=r#"zen-browser$"# title="^Picture-in-Picture$"
        open-floating true
    }

    window-rule {
        geometry-corner-radius 12
        clip-to-geometry true
        draw-border-with-background false
    }

    binds {
        Mod+Shift+W { show-hotkey-overlay; }
        Mod+T hotkey-overlay-title="Open a Terminal: kitty" { spawn "kitty"; }
        Mod+R { spawn "tofi-drun"; }

        Mod+O repeat=false { toggle-overview; }
        Mod+Q { close-window; }

        Mod+H     { focus-column-left; }
        Mod+J     { focus-window-or-workspace-down; }
        Mod+K     { focus-window-or-workspace-up; }
        Mod+L     { focus-column-right; }

        Mod+Ctrl+H     { move-column-left; }
        Mod+Ctrl+J     { move-window-down-or-to-workspace-down; }
        Mod+Ctrl+K     { move-window-up-or-to-workspace-up; }
        Mod+Ctrl+L     { move-column-right; }

        Mod+Home { focus-column-first; }
        Mod+End  { focus-column-last; }
        Mod+Ctrl+Home { move-column-to-first; }
        Mod+Ctrl+End  { move-column-to-last; }

        Mod+U              { focus-workspace-down; }
        Mod+I              { focus-workspace-up; }
        Mod+Ctrl+Page_Down { move-column-to-workspace-down; }
        Mod+Ctrl+Page_Up   { move-column-to-workspace-up; }
        Mod+Ctrl+U         { move-column-to-workspace-down; }
        Mod+Ctrl+I         { move-column-to-workspace-up; }

        Mod+Shift+Page_Down { move-workspace-down; }
        Mod+Shift+Page_Up   { move-workspace-up; }
        Mod+Shift+U         { move-workspace-down; }
        Mod+Shift+I         { move-workspace-up; }

        Mod+WheelScrollDown      cooldown-ms=150 { focus-workspace-down; }
        Mod+WheelScrollUp        cooldown-ms=150 { focus-workspace-up; }
        Mod+Ctrl+WheelScrollDown cooldown-ms=150 { move-column-to-workspace-down; }
        Mod+Ctrl+WheelScrollUp   cooldown-ms=150 { move-column-to-workspace-up; }

        Mod+WheelScrollRight      { focus-column-right; }
        Mod+WheelScrollLeft       { focus-column-left; }
        Mod+Ctrl+WheelScrollRight { move-column-right; }
        Mod+Ctrl+WheelScrollLeft  { move-column-left; }

        Mod+Shift+WheelScrollDown      { focus-column-right; }
        Mod+Shift+WheelScrollUp        { focus-column-left; }
        Mod+Ctrl+Shift+WheelScrollDown { move-column-right; }
        Mod+Ctrl+Shift+WheelScrollUp   { move-column-left; }

        Mod+1 { focus-workspace 1; }
        Mod+2 { focus-workspace 2; }
        Mod+3 { focus-workspace 3; }
        Mod+4 { focus-workspace 4; }
        Mod+5 { focus-workspace 5; }
        Mod+6 { focus-workspace 6; }
        Mod+7 { focus-workspace 7; }
        Mod+8 { focus-workspace 8; }
        Mod+9 { focus-workspace 9; }
        Mod+Ctrl+1 { move-column-to-workspace 1; }
        Mod+Ctrl+2 { move-column-to-workspace 2; }
        Mod+Ctrl+3 { move-column-to-workspace 3; }
        Mod+Ctrl+4 { move-column-to-workspace 4; }
        Mod+Ctrl+5 { move-column-to-workspace 5; }
        Mod+Ctrl+6 { move-column-to-workspace 6; }
        Mod+Ctrl+7 { move-column-to-workspace 7; }
        Mod+Ctrl+8 { move-column-to-workspace 8; }
        Mod+Ctrl+9 { move-column-to-workspace 9; }

        Mod+BracketLeft  { consume-or-expel-window-left; }
        Mod+BracketRight { consume-or-expel-window-right; }

        Mod+Comma  { consume-window-into-column; }
        Mod+Period { expel-window-from-column; }

        Mod+S { switch-preset-column-width; }
        Mod+F { maximize-column; }
        Mod+Shift+F { fullscreen-window; }
        Mod+Ctrl+F { expand-column-to-available-width; }

        Mod+C { center-column; }
        Mod+Ctrl+C { center-visible-columns; }

        Mod+Minus { set-column-width "-10%"; }
        Mod+Equal { set-column-width "+10%"; }

        Mod+Shift+Minus { set-window-height "-10%"; }
        Mod+Shift+Equal { set-window-height "+10%"; }

        Mod+V       { toggle-window-floating; }
        Mod+Shift+V { switch-focus-between-floating-and-tiling; }

        Mod+W { toggle-column-tabbed-display; }
        Mod+Shift+S { screenshot; }
        Ctrl+Print { screenshot-screen; }
        Alt+Print { screenshot-window; }

        Mod+Escape allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }
        Mod+Shift+E { quit; }
        Ctrl+Alt+Delete { quit; }
        Mod+Shift+P { power-off-monitors; }

        ${lib.optionalString (
          host == "laptop"
        ) ''Mod+Shift+L { spawn "swaylock" "--color" "000000"; }''}
    }
''
+ lib.optionalString (host == "laptop") ''
  spawn-at-startup "swww" "img" "/etc/nixos/wallpaper/laptop.jpeg"

  output "eDP-1" {
      mode "1920x1080@60"
      scale 1.25
      transform "normal"
      position x=0 y=0
  }
''
