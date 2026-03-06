{
  host,
  lib,
}:
let
  theme = import ../theme.nix;
in
{
  enable = true;
  settings = [
    {
      layer = "top";
      height = 30;
      spacing = 4;
      modules-left = [ "niri/workspaces" ];
      modules-right = [
        "tray"
      ]
      ++ lib.optionals (host == "laptop") [ "battery" ]
      ++ [
        "pulseaudio/slider"
        "clock"
      ];
      tray.spacing = 10;
      battery = {
        states = {
          warning = 30;
          critical = 15;
        };
        format = "{icon}  {capacity}%";
        format-charging = "󱐋 {capacity}%";
        format-icons = [
          "󰁺"
          "󰁻"
          "󰁼"
          "󰁽"
          "󰁾"
          "󰁿"
          "󰂀"
          "󰂁"
          "󰂂"
          "󰁹"
        ];
      };
      clock = {
        tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        format-alt = "{:%Y-%m-%d}";
      };
    }
  ];
  style = with theme.colors; ''
    * {
        font-family: "${theme.font}";
    }

    window#waybar {
        background: transparent;
        border: none;
    }

    .modules-left,
    .modules-right {
        background: ${background};
        color: ${foreground};
    }

    .modules-left {
        border-radius: 0 0 20px 0;
        padding-right: 20px;
    }

    #workspaces button {
        border-radius: 0;
        padding: 4px;
        font-size: 17px;
        transition: all 0.3s ease-out;
        color: ${foreground};
    }

    #workspaces button.active {
        background-color: ${backgroundDark};
        color: ${blue};
    }

    .modules-right {
        border-radius: 0 0 0 20px;
        padding-left: 10px;
        padding-right: 10px;
    }

    #clock {
        font-size: 20px;
    }

    #pulseaudio-slider slider {
        background: transparent;
        background-color: transparent;
        box-shadow: none;
        border: none;
    }

    #pulseaudio-slider trough {
        min-width: 200px;
        min-height: 10px;
        border-radius: 8px;
        border: none;
        background-color: ${backgroundDark};
    }

    #pulseaudio-slider highlight {
        border-radius: 8px;
        background-color: ${blue};
        border: none;
    }

    #battery {
        padding: 0 10px;
    }

    #battery.warning {
        color: ${orange};
    }

    #battery.critical {
        color: ${red};
        animation: blink 1s steps(2) infinite;
    }

    @keyframes blink {
        to { color: ${background}; }
    }
  '';
}
