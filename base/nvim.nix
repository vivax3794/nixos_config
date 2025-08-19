{ host, lib }:

{
  enable = true;
  defaultEditor = true;

  colorschemes.tokyonight = {
    enable = true;
    settings = {
      transparent = true;
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

  diagnostic.settings = {
    underline = true;
    virtual_text = true;
    virtual_lines = {
      current_line = true;
    };
    signs = false;
    update_in_insert = true;
    severity_sort = true;
  };

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
    {
      event = "BufWritePre";
      pattern = "*";
      callback = {
        __raw = ''
          function(event)
              vim.lsp.buf.format()
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
  # plugins.hardtime.enable = true;
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

  plugins.snacks = {
    enable = true;
    settings = {
      picker.enable = true;
      scroll.enable = true;
      scope.enable = true;
      dim = {
        enable = true;
        scope = {
          cursor = false;
          treesitter = {
            enabled = true;
            blocks.enabled = true;
          };

        };
      };
      indent = {
        enables = true;
        scopes = {
          enabled = true;
          underline = true;
        };
        chunk.enabled = true;
      };
    };
  };
  plugins.todo-comments = {
    enable = true;
    settings.keywords = {
      REFACTOR = {
        icon = "󰃣";
      };
      MAYBE = {
        icon = "?";
      };
      INVARIANT = {
        icon = " ";
        color = "warning";
      };
      SPEC = {
        icon = " ";
        color = "error";
      };
    };
  };

  plugins.lsp = {
    enable = true;
    inlayHints = true;
    keymaps.silent = true;
    keymaps.lspBuf = {
      "<leader>r" = "rename";
    };
    keymaps.diagnostic = {
      "<leader>e" = "open_float";
    };
  };

  plugins.rustaceanvim = {
    enable = host != "pi";
    settings.server = {
      capabilities = {
        experimental.snippetTextEdit = false;
      };

      on_attach = (
        let
          rustKeymaps = [
            {
              mode = "n";
              key = "<leader>a";
              action = ''function() vim.cmd.RustLsp("codeAction") end'';
            }
            {
              mode = "v";
              key = "<leader>a";
              action = "vim.lsp.buf.code_action";
            }
            {
              mode = "n";
              key = "K";
              action = ''function() vim.cmd.RustLsp({"hover", "actions"}) end'';
            }
            {
              mode = "n";
              key = "<leader>md";
              action = '':RustLsp moveItem down<CR>'';
            }
            {
              mode = "n";
              key = "<leader>mu";
              action = '':RustLsp moveItem up<CR>'';
            }
          ];

          # Convert to Lua keymap calls
          mkKeymapLua =
            keymap:
            if lib.hasPrefix ":" keymap.action then
              ''vim.keymap.set("${keymap.mode}", "${keymap.key}", "${keymap.action}", {silent = true, buffer = bufnr})''
            else
              ''vim.keymap.set("${keymap.mode}", "${keymap.key}", ${keymap.action}, {silent = true, buffer = bufnr})'';
        in
        {
          __raw = ''
            function(_, bufnr)
              ${lib.concatStringsSep "\n" (map mkKeymapLua rustKeymaps)}
            end
          '';
        }
      );

      default_settings."rust-analyzer" = {
        checkOnSave = true;
        check = {
          enable = true;
          command = "clippy";
          allFeatures = true;
        };
        inlayHints = {
          lifetimeElisionHints = {
            enable = "always";
            useParameterNames = true;
          };
        };
        formatOnSave.enable = true;
        cargo = {
          allFeatures = true;
          allTargets = true;
          buildScripts.rebuildOnSave = false;
        };
      };
    };
  };
  plugins.cmp = {
    enable = true;
    autoEnableSources = true;
    settings = {
      sources = [
        { name = "copilote"; }
        { name = "nvim_lsp"; }
        { name = "luasnip"; }
        { name = "path"; }
        { name = "buffer"; }
      ];

      mapping = {
        "<CR>" = "cmp.mapping.confirm({ select = true })";
        "<Down>" = "cmp.mapping.select_next_item()";
        "<Up>" = "cmp.mapping.select_prev_item()";
      };
      snippet.expand = ''
        function(args)
          require('luasnip').lsp_expand(args.body)
        end
      '';
    };
  };
  plugins.copilot-lua = {
    enable = true;
    settings = {
      suggestions = {
        auto_trigger = true;
        enable = true;
      };
    };
  };
  plugins.copilot-cmp.enable = true;

  plugins.luasnip.enable = true;

  keymaps = [
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
    {
      action = "<Cmd>lua Snacks.picker.files()<CR>";
      key = "<leader><space>";
      mode = "n";
      options.silent = true;
    }
    {
      action = "<Cmd>lua Snacks.picker.grep()<CR>";
      key = "<leader>g";
      mode = "n";
      options.silent = true;
    }
    {
      action = "<Cmd>lua Snacks.picker.lsp_workspace_symbols()<CR>";
      key = "<leader>s";
      mode = "n";
      options.silent = true;
    }
    {
      action = "<Cmd>lua Snacks.picker.diagnostics()<CR>";
      key = "<leader>d";
      mode = "n";
      options.silent = true;
    }
    {
      action = "<Cmd>lua Snacks.picker.todo_comments()<CR>";
      key = "<leader>t";
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

}
