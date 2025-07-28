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
    # {
    #   action = "<Cmd>BufferNext<CR>";
    #   key = "<C-J>";
    #   mode = "n";
    #   options.silent = true;
    # }
  ];

  # LOOKS
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
  plugins.barbar = {
    enable = true;
    settings = {
      auto_hide = 1;
      icons.button = "";
    };
  };
}
