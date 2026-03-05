{ host, lib }:
[
  {
    layer = "top";
    height = 30;
    spacing = 4;
    modules-left = [
      "niri/workspaces"
    ];
    modules-right = [
      "tray"
    ]
    ++ lib.optionals (host == "laptop") [
      "battery"
    ]
    ++ [
      "pulseaudio/slider"
      "clock"
    ];
    tray = {
      spacing = 10;
    };
    battery = {
      states = {
        warning = 30;
        critical = 15;
      };
      format = "{icon}  {capacity}%";
      format-charging = "󱐋 {capacity}%";
      format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
    };
    clock = {
      tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
      format-alt = "{:%Y-%m-%d}";
    };
  }
]
