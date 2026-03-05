{
  host,
  lib,
  inputs,
  pkgs,
}:
let
  tree-sitter-serpentine = pkgs.tree-sitter.buildGrammar {
    language = "snek";
    version = "0.1.0";
    src = inputs.tree-sitter-serpentine;
  };
in
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
      event = "FileType";
      pattern = "java";
      callback = {
        __raw = ''
          function()
            local jdtls = require('jdtls')
            local workspace_dir = vim.fn.stdpath('cache') .. '/jdtls/' .. vim.fn.fnamemodify(vim.fn.getcwd(), ':t')
            
            vim.env.JAVA_HOME = '${pkgs.jdk25}'
            
            local config = {
              cmd = {
                '${pkgs.jdt-language-server}/bin/jdtls',
                '-data', workspace_dir,
              },
              root_dir = jdtls.setup.find_root({'.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle'}),
              settings = { java = {} },
              init_options = { bundles = {} },
            }
            
            jdtls.start_or_attach(config)
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
    grammarPackages = pkgs.vimPlugins.nvim-treesitter.passthru.allGrammars ++ [
      tree-sitter-serpentine
    ];
    languageRegister.snek = "snek";
  };
  filetype.extension = {
    snek = "snek";
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
      dashboard = {
        enable = true;
        preset.keys = [
          {
            icon = " ";
            key = "f";
            desc = "Find File";
            action = ":lua Snacks.picker.files()";
          }
          {
            icon = " ";
            key = "g";
            desc = "Grep";
            action = ":lua Snacks.picker.grep()";
          }
          {
            icon = " ";
            key = "r";
            desc = "Recent Files";
            action = ":lua Snacks.picker.recent()";
          }
          {
            icon = " ";
            key = "q";
            desc = "Quit";
            action = ":qa";
          }
        ];
        sections = [
          { section = "header"; }
          {
            section = "keys";
            gap = 1;
            padding = 1;
          }
          {
            section = "recent_files";
            limit = 8;
            padding = 1;
          }
        ];
      };
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
  plugins.flash = {
    enable = true;
    settings.modes.char.enabled = false;
  };
  plugins.which-key = {
    enable = true;
    settings.spec = [
      {
        __unkeyed-1 = "<leader>m";
        group = "Move item";
      }
    ];
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
      "<leader>r" = {
        action = "rename";
        desc = "Rename symbol";
      };
    };
    keymaps.diagnostic = {
      "<leader>e" = {
        action = "open_float";
        desc = "Diagnostic float";
      };
    };
    servers.nil_ls = {
      enable = true;
      settings.formatting.command = [ "${pkgs.nixfmt}/bin/nixfmt" ];
    };
  };

  plugins.rustaceanvim = {
    enable = true;
    settings.server = {
      capabilities = {
        experimental.snippetTextEdit = false;
      };

      cmd = [
        "${inputs.fenix.packages.x86_64-linux.rust-analyzer}/bin/rust-analyzer"
      ];

      on_attach = (
        let
          rustKeymaps = [
            {
              mode = "n";
              key = "<leader>a";
              action = ''function() vim.cmd.RustLsp("codeAction") end'';
              desc = "Code action";
            }
            {
              mode = "v";
              key = "<leader>a";
              action = "vim.lsp.buf.code_action";
              desc = "Code action";
            }
            {
              mode = "n";
              key = "K";
              action = ''function() vim.cmd.RustLsp({"hover", "actions"}) end'';
              desc = "Hover actions";
            }
            {
              mode = "n";
              key = "<leader>md";
              action = ":RustLsp moveItem down<CR>";
              desc = "Move item down";
            }
            {
              mode = "n";
              key = "<leader>mu";
              action = ":RustLsp moveItem up<CR>";
              desc = "Move item up";
            }
          ];

          # Convert to Lua keymap calls
          mkKeymapLua =
            keymap:
            if lib.hasPrefix ":" keymap.action then
              ''vim.keymap.set("${keymap.mode}", "${keymap.key}", "${keymap.action}", {silent = true, buffer = bufnr, desc = "${keymap.desc}"})''
            else
              ''vim.keymap.set("${keymap.mode}", "${keymap.key}", ${keymap.action}, {silent = true, buffer = bufnr, desc = "${keymap.desc}"})'';
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
      experimental.ghost_text = true;
      sources = [
        {
          name = "nvim_lsp";
          priority = 100;
        }
        {
          name = "luasnip";
          priority = 50;
        }
        {
          name = "path";
          priority = 40;
        }
        {
          name = "buffer";
          priority = 10;
        }
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
  plugins.luasnip.enable = true;

  # plugins.jdtls.enable = true;
  extraPlugins = [ pkgs.vimPlugins.nvim-jdtls ];

  # plugins.nui.enable = true;
  plugins.hunk = {
    enable = true;
    settings.hooks = {
      on_diff_mount.__raw = ''
        function(context)
          vim.api.nvim_set_option_value("signcolumn", "yes", { win = context.winid })
        end
      '';
    };
  };

  keymaps = [
    {
      action.__raw = "function() require('flash').jump() end";
      key = "s";
      mode = [
        "n"
        "x"
        "o"
      ];
      options = {
        silent = true;
        desc = "Flash";
      };
    }
    {
      action.__raw = "function() require('flash').treesitter() end";
      key = "S";
      mode = [
        "n"
        "x"
        "o"
      ];
      options = {
        silent = true;
        desc = "Flash Treesitter";
      };
    }
    {
      action.__raw = "function() require('flash').remote() end";
      key = "r";
      mode = "o";
      options = {
        silent = true;
        desc = "Remote Flash";
      };
    }
    {
      action = ":wqa<CR>";
      key = "<leader>q";
      mode = "n";
      options = {
        silent = true;
        desc = "Save all and quit";
      };
    }
    {
      action = ":wa<CR>";
      key = "<C-s>";
      mode = "n";
      options = {
        silent = true;
        desc = "Save all";
      };
    }
    {
      action = "<ESC>:wa<CR>a";
      key = "<C-s>";
      mode = "i";
      options = {
        silent = true;
        desc = "Save all";
      };
    }
    {
      action = ":noh<CR>";
      key = "<leader>h";
      mode = "n";
      options = {
        silent = true;
        desc = "Clear highlights";
      };
    }
    {
      action = "zt";
      key = "zz";
      mode = "n";
      options = {
        silent = true;
        desc = "Scroll to top";
      };
    }
    {
      action = "<Cmd>BufferPrevious<CR>";
      key = "<C-K>";
      mode = [
        "n"
        "i"
      ];
      options = {
        silent = true;
        desc = "Previous buffer";
      };
    }
    {
      action = "<Cmd>BufferNext<CR>";
      key = "<C-J>";
      mode = [
        "n"
        "i"
      ];
      options = {
        silent = true;
        desc = "Next buffer";
      };
    }
    {
      action = "<Cmd>BufferMoveNext<CR>";
      key = "<leader>j";
      mode = "n";
      options = {
        silent = true;
        desc = "Move buffer right";
      };
    }
    {
      action = "<Cmd>BufferMovePrevious<CR>";
      key = "<leader>k";
      mode = "n";
      options = {
        silent = true;
        desc = "Move buffer left";
      };
    }
    {
      action = "<Cmd>BufferClose<CR>";
      key = "<leader>c";
      mode = "n";
      options = {
        silent = true;
        desc = "Close buffer";
      };
    }
    {
      action = "<Cmd>BufferCloseAllButCurrent<CR>";
      key = "<leader>C";
      mode = "n";
      options = {
        silent = true;
        desc = "Close other buffers";
      };
    }
    {
      action = "<Cmd>Oil --float<CR>";
      key = "<leader>o";
      mode = "n";
      options = {
        silent = true;
        desc = "Oil (current dir)";
      };
    }
    {
      action = "<Cmd>Oil --float .<CR>";
      key = "<leader>O";
      mode = "n";
      options = {
        silent = true;
        desc = "Oil (root)";
      };
    }
    {
      action = "<Cmd>lua Snacks.picker.files()<CR>";
      key = "<leader><space>";
      mode = "n";
      options = {
        silent = true;
        desc = "Find files";
      };
    }
    {
      action = "<Cmd>lua Snacks.picker.grep()<CR>";
      key = "<leader>g";
      mode = "n";
      options = {
        silent = true;
        desc = "Grep";
      };
    }
    {
      action = "<Cmd>lua Snacks.picker.lsp_workspace_symbols()<CR>";
      key = "<leader>s";
      mode = "n";
      options = {
        silent = true;
        desc = "Workspace symbols";
      };
    }
    {
      action = "<Cmd>lua Snacks.picker.diagnostics()<CR>";
      key = "<leader>d";
      mode = "n";
      options = {
        silent = true;
        desc = "Diagnostics";
      };
    }
    {
      action = "<Cmd>lua Snacks.picker.todo_comments()<CR>";
      key = "<leader>t";
      mode = "n";
      options = {
        silent = true;
        desc = "Todo comments";
      };
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
