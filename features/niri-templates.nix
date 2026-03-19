{ pkgs, lib, ... }:

let
  niri = lib.getExe pkgs.niri-unstable;
  jq = "${pkgs.jq}/bin/jq";
  anyrunBin = lib.getExe pkgs.anyrun;
  anyrunStdin = "${pkgs.anyrun}/lib/libstdin.so";

  templates = {
    rust = {
      focus = 1;
      columns = [
        {
          width = "33.3%";
          windows = [
            {
              command = lib.getExe pkgs.kitty;
              args = [
                "--directory"
                "{cwd}"
                "-e"
                "${lib.getExe pkgs.direnv}"
                "exec"
                "{cwd}"
                (lib.getExe pkgs.bacon)
                "--summary"
                "--job"
                "clippy"
              ];
            }
            {
              command = lib.getExe pkgs.kitty;
              args = [
                "--directory"
                "{cwd}"
              ];
            }
          ];
        }
        {
          width = "66.6%";
          windows = [
            {
              command = lib.getExe pkgs.kitty;
              args = [
                "--directory"
                "{cwd}"
                "-e"
                "${lib.getExe pkgs.direnv}"
                "exec"
                "{cwd}"
                "nvim"
              ];
            }
          ];
        }
      ];
    };
  };

  # Total number of windows across all columns in a template
  totalWindows = tmpl: lib.foldl' (acc: col: acc + builtins.length col.windows) 0 tmpl.columns;

  # Flatten template into spawn-order list: all windows of col 0, then col 1, etc.
  # Returns list of { command, args } attrsets
  flattenWindows = tmpl: lib.concatMap (col: col.windows) tmpl.columns;

  # Build the spawn command for a single window
  # Args containing {cwd} use double quotes (for variable expansion), others use escapeShellArg
  mkSpawnCmd =
    win:
    let
      escapeArg =
        arg:
        if lib.hasInfix "{cwd}" arg then
          "\"${builtins.replaceStrings [ "{cwd}" ] [ "$CWD" ] arg}\""
        else
          lib.escapeShellArg arg;
    in
    "${niri} msg action spawn -- ${lib.escapeShellArg win.command} ${
      lib.concatMapStringsSep " " escapeArg win.args
    }";

  # CWD picker via anyrun + zoxide
  # Anyrun stdin plugin doubles its output (selected + selected), so we take the first half
  getCwd = pkgs.writeShellScript "template-get-cwd" ''
    raw=$(${pkgs.zoxide}/bin/zoxide query -l | ${anyrunBin} --plugins ${anyrunStdin})
    [ -z "$raw" ] && exit 0
    half=$(( ''${#raw} / 2 ))
    dir="''${raw:0:$half}"
    echo "$dir"
  '';

  # Generate runner script for a single template
  mkRunner =
    name: tmpl:
    let
      windows = flattenWindows tmpl;
      total = totalWindows tmpl;

      # Build the arrangement commands
      # After spawning, windows are individual columns in spawn order (left to right).
      # For each template column with N windows, we need to consume N-1 windows into it.
      # We process left to right: focus the first window of each column, then consume extras.
      #
      # windowIndex tracks the position in the flat spawn-order list.
      # After consuming, the column structure collapses, so we track by window ID.
      arrangeCmds =
        let
          # For each column, compute the index range in the flat list
          colInfo =
            lib.foldl'
              (
                acc: col:
                let
                  startIdx = acc.nextIdx;
                  count = builtins.length col.windows;
                in
                {
                  nextIdx = startIdx + count;
                  cols = acc.cols ++ [
                    {
                      inherit startIdx count;
                      inherit (col) width;
                    }
                  ];
                }
              )
              {
                nextIdx = 0;
                cols = [ ];
              }
              tmpl.columns;
        in
        lib.concatMapStringsSep "\n" (
          ci:
          let
            # Focus the first window of this column and set width
            focusFirst = ''
              ${niri} msg action focus-window --id "$(echo "$new_ids" | ${jq} ".[${toString ci.startIdx}]")"
              ${niri} msg action set-column-width "${ci.width}"
            '';
            # Consume additional windows into this column (they are immediately to the right)
            consumeExtras = lib.concatMapStringsSep "\n" (i: ''
              ${niri} msg action consume-window-into-column
            '') (lib.range 1 (ci.count - 1));
          in
          focusFirst + consumeExtras
        ) colInfo.cols;

      # Focus command for the configured focus column
      focusCol =
        let
          focusIdx = tmpl.focus or 0;
          # Find the first window index of the focus column
          focusWindowIdx =
            lib.foldl'
              (
                acc: col:
                if acc.colIdx == focusIdx then
                  acc
                else
                  {
                    colIdx = acc.colIdx + 1;
                    windowIdx = acc.windowIdx + builtins.length col.windows;
                  }
              )
              {
                colIdx = 0;
                windowIdx = 0;
              }
              tmpl.columns;
        in
        ''
          ${niri} msg action focus-window --id "$(echo "$new_ids" | ${jq} ".[${toString focusWindowIdx.windowIdx}]")"
        '';

    in
    pkgs.writeShellScript "niri-template-${name}" ''
      set -euo pipefail
      CWD="$1"

      before=$(${niri} msg --json windows | ${jq} '[.[].id] | sort')

      # Spawn all windows
      ${lib.concatMapStringsSep "\n" mkSpawnCmd windows}

      # Wait for all windows to appear
      expected=${toString total}
      elapsed=0
      while true; do
        current=$(${niri} msg --json windows | ${jq} '[.[].id] | sort')
        new_count=$(${jq} -n --argjson b "$before" --argjson c "$current" \
          '($c - $b) | length')
        if [ "$new_count" -ge "$expected" ]; then
          break
        fi
        sleep 0.2
        elapsed=$((elapsed + 1))
        if [ "$elapsed" -ge 50 ]; then
          echo "Timeout waiting for windows to spawn" >&2
          exit 1
        fi
      done

      # Get new window IDs in spawn (ascending) order
      new_ids=$(${jq} -n --argjson b "$before" --argjson c "$current" \
        '$c - $b | sort')

      # Arrange columns and consume tabs
      ${arrangeCmds}

      # Focus configured column
      ${focusCol}
    '';

  templateRunners = lib.mapAttrs mkRunner templates;
  templateNames = builtins.attrNames templates;

  picker = pkgs.writeShellScript "niri-template-picker" ''
    set -euo pipefail

    # Pick template
    selected=$(printf "${lib.concatStringsSep "\\n" templateNames}" \
      | ${anyrunBin} --plugins ${anyrunStdin})
    [ -z "$selected" ] && exit 0

    # Pick CWD
    CWD=$(${getCwd})
    [ -z "$CWD" ] && exit 0

    case "$selected" in
      ${lib.concatStrings (
        lib.mapAttrsToList (name: runner: ''
          *${name}*) ${runner} "$CWD" ;;
        '') templateRunners
      )}
    esac
  '';
in
{
  programs.niri.settings.binds."Mod+P".action.spawn = [ "${picker}" ];
}
