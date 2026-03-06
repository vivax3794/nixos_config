{
  pkgs,
}:
let
  theme = import ../theme.nix;
in
{
  enable = true;
  config = {
    x.fraction = 0.5;
    y.fraction = 0.3;
    width.absolute = 600;
    hideIcons = false;
    closeOnClick = true;
    showResultsImmediately = true;
    maxEntries = 7;
    hidePluginInfo = true;
    layer = "overlay";
    plugins = map (p: "${pkgs.anyrun}/lib/${p}") [
      "libapplications.so"
      "librink.so"
      "libshell.so"
      "libwebsearch.so"
      "libniri_focus.so"
      "libnix_run.so"
    ];
  };
  extraConfigFiles."nix-run.ron".text = ''
    Config(
      prefix: ":nr ",
      max_entries: 5,
      allow_unfree: true,
    )
  '';
  extraConfigFiles."websearch.ron".text = ''
    Config(
      prefix: "?",
      engines: [DuckDuckGo],
    )
  '';
  extraCss = with theme.colors; ''
    * {
      font-family: "${theme.font}";
      font-size: 15px;
    }

    @keyframes slide-in {
      from {
        opacity: 0;
        margin-top: -20px;
      }
      to {
        opacity: 1;
        margin-top: 0;
      }
    }

    window {
      background: transparent;
    }

    .main {
      background-color: alpha(${background}, 0.88);
      border: 2px solid alpha(${blue}, 0.5);
      border-radius: 16px;
      padding: 12px;
      animation: slide-in 250ms ease-out;
    }

    entry {
      background-color: alpha(${selection}, 0.6);
      border: 1px solid alpha(${comment}, 0.3);
      border-radius: 10px;
      padding: 8px 16px;
      margin-bottom: 8px;
      min-height: 32px;
      caret-color: ${purple};
      color: ${foreground};
    }

    text {
      color: ${foreground};
    }

    entry:focus {
      border-color: alpha(${blue}, 0.6);
    }

    .matches {
      background-color: transparent;
    }

    list.plugin {
      background-color: transparent;
    }

    .match {
      background: transparent;
      padding: 4px 8px;
      margin: 2px 4px;
      border-radius: 8px;
      transition: all 200ms ease;
    }

    .match:hover {
      background-color: alpha(${selection}, 0.4);
    }

    .match:selected {
      background-color: alpha(${blue}, 0.2);
      border: 1px solid alpha(${blue}, 0.3);
    }

    .match .title {
      color: ${foreground};
      font-weight: 500;
    }

    .match .description {
      color: ${comment};
      font-size: 13px;
    }

    .match:selected .title {
      color: ${cyan};
    }

    .plugin {
      padding: 2px;
    }
  '';
}
