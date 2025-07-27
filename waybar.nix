[
  {
    height = 30;
    spacing = 4;
    modules-left = [
      "niri/workspaces"
    ];
    modules-right = [
      "tray"
      "battery"
      "pulseaudio/slider"
      "clock"
    ];
    tray = {
      spacing = 10;
    };
    clock = {
      tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
      format-alt = "{:%Y-%m-%d}";
    };
  }
]
