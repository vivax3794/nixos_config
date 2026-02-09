# Smart terminal feature:
# - Mod+T: If kitty is focused, open new window in current dir; otherwise launch kitty
# - Ctrl+T in kitty: Open new window in current dir
{ pkgs, lib, ... }:

let
  smartTerminal = pkgs.writeShellScript "smart-terminal" ''
    if ${lib.getExe pkgs.niri} msg focused-window | ${lib.getExe pkgs.ripgrep} ".*kitty.*" >/dev/null; then
      ${pkgs.ydotool}/bin/ydotool key 29:1 20:1 20:0 29:0  # ctrl down, t down, t up, ctrl up
    else
      exec ${lib.getExe pkgs.kitty}
    fi
  '';
in
{
  programs.niri.settings.binds."Mod+T".action.spawn = [ "${smartTerminal}" ];

  programs.kitty.keybindings."ctrl+t" = "launch --cwd=current --type=os-window";

  programs.ydotool.enable = true;
}
