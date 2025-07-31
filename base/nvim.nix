{ host, lib }:

{
  enable = true;
  defaultEditor = true;

  colorschemes.tokyonight = {
    enable = true;
    settings = {
      on_highlights = ''
        function(highlights, colors)
        	highlights.LineNr = {fg = "#ff9e64"}
        	highlights.LineNrAbove = {fg = "#a1f291"}
        	highlights.LineNrBelow = {fg = "#a1f291"}
        end'';
    };
  };
  colorscheme = "tokyonight-night";

  globals = {
    mapleader = ",";
  };
  opts = {
    number = true;
    relativenumber = true;
    signcolumn = "no";

    cmdheight = 0;
    laststatus = 0;

    scrolloff = if (host == "desktop") then 15 else 2;
    expandtab = true;
    tabstop = 4;
    softtabstop = 4;
    shiftwidth = 4;
  };

  keymaps = [
    # QOL
    {
      action = ":wqa<CR>";
      key = "<leader>q";
      mode = "n";
      options.silent = true;
    }
    {
      action = ":wa<CR>";
      key = "<C-s>";
      mode = "n";
      options.silent = true;
    }
    {
      action = "<ESC>:wa<CR>a";
      key = "<C-s>";
      mode = "i";
      options.silent = true;
    }
    {
      action = ":noh<CR>";
      key = "<leader>h";
      mode = "n";
      options.silent = true;
    }
    {
      action = "zt";
      key = "zz";
      mode = "n";
      options.silent = true;
    }

    # Tabs
    {
      action = "<Cmd>BufferPrevious<CR>";
      key = "<C-K>";
      mode = [
        "n"
        "i"
      ];
      options.silent = true;
    }
    {
      action = "<Cmd>BufferNext<CR>";
      key = "<C-J>";
      mode = [
        "n"
        "i"
      ];
      options.silent = true;
    }
    {
      action = "<Cmd>BufferMoveNext<CR>";
      key = "<leader>j";
      mode = "n";
      options.silent = true;
    }
    {
      action = "<Cmd>BufferMovePrevious<CR>";
      key = "<leader>k";
      mode = "n";
      options.silent = true;
    }
    {
      action = "<Cmd>BufferClose<CR>";
      key = "<leader>c";
      mode = "n";
      options.silent = true;
    }
    {
      action = "<Cmd>BufferCloseAllButCurrent<CR>";
      key = "<leader>C";
      mode = "n";
      options.silent = true;
    }
    {
      action = "<Cmd>Oil --float<CR>";
      key = "<leader>o";
      mode = "n";
      options.silent = true;
    }
    {
      action = "<Cmd>Oil --float .<CR>";
      key = "<leader>O";
      mode = "n";
      options.silent = true;
    }
  ]
  # Disable copy on delete/change
  ++ lib.flatten (
    map
      (letter: [
        {
          mode = [
            "n"
            "v"
          ];
          key = letter;
          action = ''"_${letter}'';
          options.noremap = true;
        }
        {
          mode = "n";
          key = lib.toUpper letter;
          action = ''"_${lib.toUpper letter}'';
          options.noremap = true;
        }
        {
          mode = "n";
          key = "${letter}${letter}";
          action = ''"_${letter}${letter}'';
          options.noremap = true;
        }
      ])
      [
        "c"
        "d"
      ]
  );

  autoCmd = [
    {
      event = "User";
      pattern = "OilActionsPost";
      callback = {
        __raw = ''
          function(event)
            if event.data.actions.type == "move" then
              Snacks.rename.on_rename_file(event.data.actions.src_url, event.data.actions.dest_url)
            end
          end
        '';
      };
    }
  ];

  plugins.treesitter = {
    enable = true;
    settings = {
      highlight.enable = true;
      indent.enable = true;
    };
  };
  plugins.noice = {
    enable = true;
  };
  plugins.web-devicons.enable = true;
  plugins.mini-icons.enable = true;
  plugins.barbar = {
    enable = true;
    settings = {
      auto_hide = 1;
      icons.button = "";
    };
  };
  plugins.nvim-autopairs.enable = true;
  plugins.hardtime.enable = true;
  plugins.oil.enable = true;
  plugins.spider = {
    enable = true;
    keymaps = {
      silent = true;
      motions = {
        w = "w";
        e = "e";
        b = "b";
      };

    };
  };
}
