let
  harpoonSlots = [
    1
    2
    3
    4
    5
  ];

  harpoonSelect =
    slot:
    let
      index = builtins.toString slot;
    in
    {
      mode = "n";
      key = "<leader>${index}";
      action.__raw = ''
        function()
          require("harpoon"):list():select(${index})
        end
      '';
      options.desc = "Harpoon ${index}";
    };

  harpoonSet =
    slot:
    let
      index = builtins.toString slot;
    in
    {
      mode = "n";
      key = "<leader>h${index}";
      action.__raw = ''
        function()
          require("harpoon"):list():replace_at(${index})
        end
      '';
      options.desc = "Set Harpoon ${index}";
    };
in
{
  programs.nixvim.keymaps = [
    {
      mode = "n";
      key = "<leader>w";
      action = "<cmd>w<cr>";
      options.desc = "Write";
    }
    {
      mode = "n";
      key = "<leader>q";
      action = "<cmd>q<cr>";
      options.desc = "Quit";
    }
    {
      mode = "n";
      key = "<leader>e";
      action.__raw = ''
        function()
          local root = _G.KaneProjectRoot(0)
          vim.cmd("Neotree toggle dir=" .. vim.fn.fnameescape(root))
        end
      '';
      options.desc = "Explorer (root dir)";
    }
    {
      mode = "n";
      key = "<leader>E";
      action = "<cmd>Neotree toggle dir=.<cr>";
      options.desc = "Explorer (cwd)";
    }
    {
      mode = "n";
      key = "<leader>fe";
      action.__raw = ''
        function()
          local root = _G.KaneProjectRoot(0)
          vim.cmd("Neotree toggle dir=" .. vim.fn.fnameescape(root))
        end
      '';
      options.desc = "Explorer (root dir)";
    }
    {
      mode = "n";
      key = "<leader>fE";
      action = "<cmd>Neotree toggle dir=.<cr>";
      options.desc = "Explorer (cwd)";
    }
    {
      mode = "n";
      key = "<leader><space>";
      action.__raw = ''
        function()
          local root = _G.KaneProjectRoot(0)
          require("fzf-lua").files({ cwd = root })
        end
      '';
      options.desc = "Find files (root dir)";
    }
    {
      mode = "n";
      key = "<leader>/";
      action.__raw = ''
        function()
          local root = _G.KaneProjectRoot(0)
          require("fzf-lua").live_grep({ cwd = root })
        end
      '';
      options.desc = "Grep (root dir)";
    }
    {
      mode = "n";
      key = "<leader>ff";
      action.__raw = ''
        function()
          local root = _G.KaneProjectRoot(0)
          require("fzf-lua").files({ cwd = root })
        end
      '';
      options.desc = "Find files (root dir)";
    }
    {
      mode = "n";
      key = "<leader>fF";
      action = "<cmd>FzfLua files<cr>";
      options.desc = "Find files (cwd)";
    }
    {
      mode = "n";
      key = "<leader>fg";
      action.__raw = ''
        function()
          local root = _G.KaneProjectRoot(0)
          require("fzf-lua").live_grep({ cwd = root })
        end
      '';
      options.desc = "Grep (root dir)";
    }
    {
      mode = "n";
      key = "<leader>sG";
      action = "<cmd>FzfLua live_grep<cr>";
      options.desc = "Grep (cwd)";
    }
    {
      mode = "n";
      key = "<leader>sg";
      action.__raw = ''
        function()
          local root = _G.KaneProjectRoot(0)
          require("fzf-lua").live_grep({ cwd = root })
        end
      '';
      options.desc = "Grep (root dir)";
    }
    {
      mode = "n";
      key = "<leader>fb";
      action = "<cmd>FzfLua buffers<cr>";
      options.desc = "Buffers";
    }
    {
      mode = "n";
      key = "<leader>fh";
      action = "<cmd>FzfLua helptags<cr>";
      options.desc = "Help";
    }
    {
      mode = "n";
      key = "<leader>fr";
      action = "<cmd>FzfLua oldfiles<cr>";
      options.desc = "Recent files";
    }
    {
      mode = "n";
      key = "<leader>fR";
      action = "<cmd>FzfLua resume<cr>";
      options.desc = "Resume picker";
    }
    {
      mode = "n";
      key = "<leader>sd";
      action = "<cmd>FzfLua diagnostics_document<cr>";
      options.desc = "Document diagnostics";
    }
    {
      mode = "n";
      key = "<leader>sD";
      action = "<cmd>FzfLua diagnostics_workspace<cr>";
      options.desc = "Workspace diagnostics";
    }
    {
      mode = "n";
      key = "<leader>ss";
      action = "<cmd>FzfLua lsp_document_symbols<cr>";
      options.desc = "Document symbols";
    }
    {
      mode = "n";
      key = "<leader>sS";
      action = "<cmd>FzfLua lsp_workspace_symbols<cr>";
      options.desc = "Workspace symbols";
    }
    {
      mode = "n";
      key = "<leader>sr";
      action = "<cmd>FzfLua lsp_references<cr>";
      options.desc = "References";
    }
    {
      mode = "n";
      key = "<leader>si";
      action = "<cmd>FzfLua lsp_implementations<cr>";
      options.desc = "Implementations";
    }
    {
      mode = "n";
      key = "<leader>sT";
      action = "<cmd>FzfLua lsp_typedefs<cr>";
      options.desc = "Type definitions";
    }
    {
      mode = "c";
      key = "<S-Enter>";
      action.__raw = ''
        function()
          require("noice").redirect(vim.fn.getcmdline())
        end
      '';
      options.desc = "Redirect cmdline";
    }
    {
      mode = "n";
      key = "<leader>snh";
      action = "<cmd>Noice history<cr>";
      options.desc = "Noice history";
    }
    {
      mode = "n";
      key = "<leader>snl";
      action = "<cmd>Noice last<cr>";
      options.desc = "Noice last message";
    }
    {
      mode = "n";
      key = "<leader>sna";
      action = "<cmd>Noice all<cr>";
      options.desc = "Noice all";
    }
    {
      mode = "n";
      key = "<leader>snd";
      action = "<cmd>Noice dismiss<cr>";
      options.desc = "Dismiss notifications";
    }
    {
      mode = "n";
      key = "<leader>gg";
      action.__raw = ''
        function()
          vim.cmd("tabnew")
          vim.cmd("terminal lazygit")
          vim.cmd("startinsert")
        end
      '';
      options.desc = "LazyGit";
    }
    {
      mode = "n";
      key = "]h";
      action.__raw = ''
        function()
          if vim.wo.diff then
            vim.cmd("normal! ]c")
          else
            require("gitsigns").nav_hunk("next")
          end
        end
      '';
      options.desc = "Next hunk";
    }
    {
      mode = "n";
      key = "[h";
      action.__raw = ''
        function()
          if vim.wo.diff then
            vim.cmd("normal! [c")
          else
            require("gitsigns").nav_hunk("prev")
          end
        end
      '';
      options.desc = "Previous hunk";
    }
    {
      mode = "n";
      key = "<leader>ghp";
      action.__raw = "function() require('gitsigns').preview_hunk() end";
      options.desc = "Preview hunk";
    }
    {
      mode = "n";
      key = "<leader>ghs";
      action.__raw = "function() require('gitsigns').stage_hunk() end";
      options.desc = "Stage hunk";
    }
    {
      mode = "v";
      key = "<leader>ghs";
      action.__raw = ''
        function()
          require("gitsigns").stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end
      '';
      options.desc = "Stage hunk";
    }
    {
      mode = "n";
      key = "<leader>ghr";
      action.__raw = "function() require('gitsigns').reset_hunk() end";
      options.desc = "Reset hunk";
    }
    {
      mode = "v";
      key = "<leader>ghr";
      action.__raw = ''
        function()
          require("gitsigns").reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end
      '';
      options.desc = "Reset hunk";
    }
    {
      mode = "n";
      key = "<leader>ghS";
      action.__raw = "function() require('gitsigns').stage_buffer() end";
      options.desc = "Stage buffer";
    }
    {
      mode = "n";
      key = "<leader>ghR";
      action.__raw = "function() require('gitsigns').reset_buffer() end";
      options.desc = "Reset buffer";
    }
    {
      mode = "n";
      key = "<leader>ghb";
      action.__raw = "function() require('gitsigns').blame_line({ full = true }) end";
      options.desc = "Blame line";
    }
    {
      mode = "n";
      key = "<leader>ghd";
      action.__raw = "function() require('gitsigns').diffthis() end";
      options.desc = "Diff this";
    }
    {
      mode = "n";
      key = "<leader>xx";
      action = "<cmd>Trouble diagnostics toggle<cr>";
      options.desc = "Diagnostics";
    }
    {
      mode = "n";
      key = "<leader>xt";
      action = "<cmd>TodoTrouble<cr>";
      options.desc = "Todos";
    }
    {
      mode = "n";
      key = "<leader>cf";
      action.__raw = ''
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end
      '';
      options.desc = "Format";
    }
    {
      mode = "n";
      key = "<leader>ci";
      action.__raw = "_G.KaneToggleInlayHints";
      options.desc = "Toggle inlay hints";
    }
    {
      mode = "n";
      key = "<leader>cr";
      action.__raw = "vim.lsp.buf.rename";
      options.desc = "Rename";
    }
    {
      mode = "n";
      key = "<leader>ha";
      action.__raw = ''
        function()
          require("harpoon"):list():add()
        end
      '';
      options.desc = "Add Harpoon file";
    }
    {
      mode = "n";
      key = "<leader>hh";
      action.__raw = ''
        function()
          local harpoon = require("harpoon")
          harpoon.ui:toggle_quick_menu(harpoon:list())
        end
      '';
      options.desc = "Harpoon menu";
    }
    {
      mode = "v";
      key = ">";
      action = ">gv";
      options.desc = "Indent selection";
    }
    {
      mode = "v";
      key = "<";
      action = "<gv";
      options.desc = "Dedent selection";
    }
    {
      mode = [
        "x"
        "o"
      ];
      key = "af";
      action.__raw = ''
        function()
          require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
        end
      '';
      options.desc = "Around function";
    }
    {
      mode = [
        "x"
        "o"
      ];
      key = "if";
      action.__raw = ''
        function()
          require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
        end
      '';
      options.desc = "Inside function";
    }
    {
      mode = [
        "x"
        "o"
      ];
      key = "ac";
      action.__raw = ''
        function()
          require("nvim-treesitter-textobjects.select").select_textobject("@class.outer", "textobjects")
        end
      '';
      options.desc = "Around class";
    }
    {
      mode = [
        "x"
        "o"
      ];
      key = "ic";
      action.__raw = ''
        function()
          require("nvim-treesitter-textobjects.select").select_textobject("@class.inner", "textobjects")
        end
      '';
      options.desc = "Inside class";
    }
    {
      mode = [
        "x"
        "o"
      ];
      key = "aa";
      action.__raw = ''
        function()
          require("nvim-treesitter-textobjects.select").select_textobject("@parameter.outer", "textobjects")
        end
      '';
      options.desc = "Around argument";
    }
    {
      mode = [
        "x"
        "o"
      ];
      key = "ia";
      action.__raw = ''
        function()
          require("nvim-treesitter-textobjects.select").select_textobject("@parameter.inner", "textobjects")
        end
      '';
      options.desc = "Inside argument";
    }
    {
      mode = "n";
      key = "]f";
      action.__raw = ''
        function()
          require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer", "textobjects")
        end
      '';
      options.desc = "Next function";
    }
    {
      mode = "n";
      key = "[f";
      action.__raw = ''
        function()
          require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer", "textobjects")
        end
      '';
      options.desc = "Previous function";
    }

    {
      mode = "n";
      key = "gd";
      action.__raw = "vim.lsp.buf.definition";
      options.desc = "Goto definition";
    }
    {
      mode = "n";
      key = "gD";
      action.__raw = "vim.lsp.buf.declaration";
      options.desc = "Goto declaration";
    }
    {
      mode = "n";
      key = "gr";
      action.__raw = "vim.lsp.buf.references";
      options.desc = "References";
    }
    {
      mode = "n";
      key = "gy";
      action.__raw = "vim.lsp.buf.type_definition";
      options.desc = "Type definition";
    }
    {
      mode = "n";
      key = "gI";
      action.__raw = "vim.lsp.buf.implementation";
      options.desc = "Implementation";
    }
    {
      mode = "n";
      key = "K";
      action.__raw = "vim.lsp.buf.hover";
      options.desc = "Hover";
    }
    {
      mode = "n";
      key = "<leader>rn";
      action.__raw = "vim.lsp.buf.rename";
      options.desc = "Rename";
    }
    {
      mode = "n";
      key = "<leader>ca";
      action.__raw = "vim.lsp.buf.code_action";
      options.desc = "Code action";
    }
    {
      mode = "n";
      key = "<leader>cd";
      action.__raw = "function() vim.diagnostic.open_float({ source = true }) end";
      options.desc = "Line diagnostics";
    }
    {
      mode = "n";
      key = "[d";
      action.__raw = "function() vim.diagnostic.jump({ count = -1, float = true }) end";
      options.silent = true;
    }
    {
      mode = "n";
      key = "]d";
      action.__raw = "function() vim.diagnostic.jump({ count = 1, float = true }) end";
      options.silent = true;
    }

    {
      mode = "n";
      key = "<C-h>";
      action = "<cmd>TmuxNavigateLeft<cr>";
      options = {
        desc = "Window left";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<C-j>";
      action = "<cmd>TmuxNavigateDown<cr>";
      options = {
        desc = "Window down";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<C-k>";
      action = "<cmd>TmuxNavigateUp<cr>";
      options = {
        desc = "Window up";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<C-l>";
      action = "<cmd>TmuxNavigateRight<cr>";
      options = {
        desc = "Window right";
        silent = true;
      };
    }
    {
      mode = "t";
      key = "<Esc><Esc>";
      action = "<C-\\><C-n>";
      options.silent = true;
    }
  ]
  ++ map harpoonSelect harpoonSlots
  ++ map harpoonSet harpoonSlots;
}
