{ pkgs, lib, ... }:
{
  programs.fish.interactiveShellInit = ''
    function __command_notify --on-event fish_postexec
      set -l exit_status $status
      set -l threshold 10000

      if test $CMD_DURATION -lt $threshold
        return
      end

      set -l blacklist nvim vim vi nano less more man bacon claude lazygit btop htop top watch tail ssh fish nix-shell direnv

      set -l cmd (string split ' ' -- $argv[1])[1]
      set cmd (basename $cmd)

      if contains -- $cmd $blacklist
        return
      end

      set -l focused (${lib.getExe pkgs.niri-unstable} msg focused-window 2>/dev/null)
      set -l focused_pid (echo "$focused" | ${pkgs.gawk}/bin/awk '/PID:/ {print $2}')
      if test "$focused_pid" = "$KITTY_PID"
        return
      end

      set -l duration_sec (math "$CMD_DURATION / 1000")
      if test $exit_status -ne 0
        ${pkgs.libnotify}/bin/notify-send -i dialog-error -t 5000 "Command failed" "$cmd failed after $duration_sec""s"
      else
        ${pkgs.libnotify}/bin/notify-send -i dialog-information -t 5000 "Command finished" "$cmd took $duration_sec""s"
      end
    end
  '';
}
