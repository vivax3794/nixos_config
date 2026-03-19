# Smart terminal feature:
# - Mod+T: If kitty is focused, open new kitty instance in the focused shell's cwd; otherwise launch kitty
# - Ctrl+T in kitty: Open new os-window in current dir (kitty-native)
# Requires kitty remote control (socket-only) to reliably query the focused window's cwd.
{ pkgs, lib, ... }:

let
  kittySocket = "unix:/tmp/kitty-{kitty_pid}";

  smartTerminal = pkgs.writeShellScript "smart-terminal" ''
    focused=$(${lib.getExe pkgs.niri-unstable} msg focused-window 2>/dev/null)
    if echo "$focused" | ${lib.getExe pkgs.ripgrep} -q 'App ID: "kitty"'; then
      kitty_pid=$(echo "$focused" | ${pkgs.gawk}/bin/awk '/PID:/ {print $2}')
      socket="unix:/tmp/kitty-$kitty_pid"
      # Query the focused kitty window's shell pid via remote control
      shell_pid=$(${lib.getExe pkgs.kitty} @ --to "$socket" ls 2>/dev/null \
        | ${pkgs.jq}/bin/jq -r '.[].tabs[].windows[] | select(.is_focused) | .pid')
      if [ -n "$shell_pid" ] && [ -d "/proc/$shell_pid/cwd" ]; then
        cwd=$(readlink "/proc/$shell_pid/cwd")
        exec ${lib.getExe pkgs.kitty} --directory "$cwd"
      fi
    fi
    exec ${lib.getExe pkgs.kitty}
  '';
in
{
  programs.niri.settings.binds."Mod+T".action.spawn = [ "${smartTerminal}" ];
  programs.kitty.keybindings."ctrl+t" = "launch --cwd=current --type=os-window";
  programs.kitty.settings = {
    allow_remote_control = "socket-only";
    listen_on = kittySocket;
  };
}
