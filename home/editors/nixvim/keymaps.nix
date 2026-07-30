let
  harpoonSlots = [
    1
    2
    3
    4
    5
    6
    7
    8
    9
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
      key = "<C-s>";
      action = "<cmd>w<cr>";
      options.desc = "Write";
    }
    {
      mode = "n";
      key = "<leader>qq";
      action = "<cmd>qa<cr>";
      options.desc = "Quit all";
    }
    {
      mode = "n";
      key = "<leader>-";
      action = "<C-w>s";
      options.desc = "Split below";
    }
    {
      mode = "n";
      key = "<leader>|";
      action = "<C-w>v";
      options.desc = "Split right";
    }
    {
      mode = "n";
      key = "<leader>wd";
      action = "<cmd>close<cr>";
      options.desc = "Close window";
    }
    {
      mode = "n";
      key = "<leader>e";
      action.__raw = ''
        function()
          local root = _G.ProjectRoot(0)
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
          local root = _G.ProjectRoot(0)
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
          local root = _G.ProjectRoot(0)
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
          local root = _G.ProjectRoot(0)
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
          local root = _G.ProjectRoot(0)
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
          local root = _G.ProjectRoot(0)
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
          local root = _G.ProjectRoot(0)
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
      key = "<leader>sR";
      action = "<cmd>FzfLua lsp_references<cr>";
      options.desc = "LSP references";
    }
    {
      mode = [
        "n"
        "v"
      ];
      key = "<leader>sr";
      action.__raw = ''
        function()
          local grug = require("grug-far")
          local options = {
            transient = true,
            prefills = { paths = _G.ProjectRoot(0) },
          }
          if vim.fn.mode():find("v") then
            options.prefills.search = vim.fn.getregion(vim.fn.getpos("."), vim.fn.getpos("v"), { type = vim.fn.mode() })
          end
          grug.open(options)
        end
      '';
      options.desc = "Search and replace (root dir)";
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
      key = "<leader>snn";
      action = "<cmd>Notifications<cr>";
      options.desc = "Notification history";
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
      action.__raw = "_G.LazyGit";
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
      key = "<leader>bd";
      action.__raw = "_G.DeleteBuffer";
      options.desc = "Delete buffer";
    }
    {
      mode = "n";
      key = "<leader>bD";
      action = "<cmd>close<cr>";
      options.desc = "Close window";
    }
    {
      mode = "n";
      key = "<leader>bo";
      action.__raw = "_G.DeleteOtherBuffers";
      options.desc = "Delete other buffers";
    }
    {
      mode = "n";
      key = "<leader>bh";
      action.__raw = "_G.DeleteHiddenBuffers";
      options.desc = "Delete hidden buffers";
    }
    {
      mode = "n";
      key = "<leader>cf";
      action.__raw = ''
        function()
          require("conform").format({ async = true, lsp_format = "fallback", timeout_ms = 5000 })
        end
      '';
      options.desc = "Format";
    }
    {
      mode = "n";
      key = "<leader>ci";
      action.__raw = "_G.ToggleInlayHints";
      options.desc = "Toggle inlay hints";
    }
    {
      mode = "n";
      key = "<leader>cr";
      action.__raw = ''
        function()
          return ":IncRename " .. vim.fn.expand("<cword>")
        end
      '';
      options = {
        desc = "Rename";
        expr = true;
      };
    }
    {
      mode = "n";
      key = "<leader>H";
      action.__raw = ''
        function()
          require("harpoon"):list():add()
        end
      '';
      options.desc = "Add Harpoon file";
    }
    {
      mode = "n";
      key = "<leader>h";
      action.__raw = ''
        function()
          local harpoon = require("harpoon")
          harpoon.ui:toggle_quick_menu(harpoon:list())
        end
      '';
      options.desc = "Harpoon menu";
    }
    {
      mode = "n";
      key = "<leader>cp";
      action = "<cmd>MarkdownPreviewToggle<cr>";
      options.desc = "Markdown preview";
    }
    {
      mode = "n";
      key = "<leader>um";
      action = "<cmd>RenderMarkdown toggle<cr>";
      options.desc = "Toggle rendered Markdown";
    }
    {
      mode = "n";
      key = "<leader>qs";
      action.__raw = "function() require('persistence').load() end";
      options.desc = "Restore session";
    }
    {
      mode = "n";
      key = "<leader>qS";
      action.__raw = "function() require('persistence').select() end";
      options.desc = "Select session";
    }
    {
      mode = "n";
      key = "<leader>qd";
      action.__raw = "function() require('persistence').stop() end";
      options.desc = "Do not save session";
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
      key = "gD";
      action.__raw = ''
        function()
          local client = vim.lsp.get_clients({ bufnr = 0, name = "vtsls" })[1]
          if not client then
            return vim.lsp.buf.declaration()
          end
          local params = vim.lsp.util.make_position_params(0, "utf-16")
          client:exec_cmd({
            command = "typescript.goToSourceDefinition",
            arguments = { params.textDocument.uri, params.position },
          }, { bufnr = 0 })
        end
      '';
      options.desc = "Goto source definition";
    }
    {
      mode = "n";
      key = "gR";
      action.__raw = ''
        function()
          local client = vim.lsp.get_clients({ bufnr = 0, name = "vtsls" })[1]
          if client then
            client:exec_cmd({
              command = "typescript.findAllFileReferences",
              arguments = { vim.uri_from_bufnr(0) },
            }, { bufnr = 0 })
          end
        end
      '';
      options.desc = "File references";
    }
    {
      mode = "n";
      key = "<leader>cM";
      action.__raw = ''
        function()
          vim.lsp.buf.code_action({ apply = true, context = { only = { "source.addMissingImports.ts" }, diagnostics = {} } })
        end
      '';
      options.desc = "Add missing imports";
    }
    {
      mode = "n";
      key = "<leader>cD";
      action.__raw = ''
        function()
          vim.lsp.buf.code_action({ apply = true, context = { only = { "source.fixAll.ts" }, diagnostics = {} } })
        end
      '';
      options.desc = "Fix all TypeScript diagnostics";
    }
    {
      mode = "n";
      key = "<leader>cV";
      action = "<cmd>VtsExec select_ts_version<cr>";
      options.desc = "Select TypeScript version";
    }
    {
      mode = [
        "n"
        "v"
      ];
      key = "<leader>ca";
      action = "<cmd>FzfLua lsp_code_actions<cr>";
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
      mode = [
        "n"
        "t"
      ];
      key = "<C-h>";
      action = "<cmd>TmuxNavigateLeft<cr>";
      options = {
        desc = "Window left";
        silent = true;
      };
    }
    {
      mode = [
        "n"
        "t"
      ];
      key = "<C-j>";
      action = "<cmd>TmuxNavigateDown<cr>";
      options = {
        desc = "Window down";
        silent = true;
      };
    }
    {
      mode = [
        "n"
        "t"
      ];
      key = "<C-k>";
      action = "<cmd>TmuxNavigateUp<cr>";
      options = {
        desc = "Window up";
        silent = true;
      };
    }
    {
      mode = [
        "n"
        "t"
      ];
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
    {
      mode = [
        "n"
        "t"
      ];
      key = "<C-/>";
      action.__raw = "function() Snacks.terminal() end";
      options.desc = "Toggle terminal";
    }
    {
      mode = "n";
      key = "<leader>ft";
      action.__raw = "function() Snacks.terminal(nil, { cwd = _G.ProjectRoot(0) }) end";
      options.desc = "Terminal (root dir)";
    }
    {
      mode = [
        "n"
        "x"
        "o"
      ];
      key = "s";
      action.__raw = "function() require('flash').jump() end";
      options.desc = "Flash";
    }
    {
      mode = [
        "n"
        "x"
        "o"
      ];
      key = "S";
      action.__raw = "function() require('flash').treesitter() end";
      options.desc = "Flash Treesitter";
    }
    {
      mode = "o";
      key = "r";
      action.__raw = "function() require('flash').remote() end";
      options.desc = "Remote Flash";
    }
    {
      mode = "n";
      key = "<leader>db";
      action.__raw = "function() require('dap').toggle_breakpoint() end";
      options.desc = "Toggle breakpoint";
    }
    {
      mode = "n";
      key = "<leader>dB";
      action.__raw = ''
        function()
          require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
        end
      '';
      options.desc = "Conditional breakpoint";
    }
    {
      mode = "n";
      key = "<leader>dc";
      action.__raw = "function() require('dap').continue() end";
      options.desc = "Run/continue";
    }
    {
      mode = "n";
      key = "<leader>da";
      action.__raw = "function() require('dap').continue({ before = require('dap.ext.vscode').getconfigs }) end";
      options.desc = "Run with arguments";
    }
    {
      mode = "n";
      key = "<leader>di";
      action.__raw = "function() require('dap').step_into() end";
      options.desc = "Step into";
    }
    {
      mode = "n";
      key = "<leader>do";
      action.__raw = "function() require('dap').step_out() end";
      options.desc = "Step out";
    }
    {
      mode = "n";
      key = "<leader>dO";
      action.__raw = "function() require('dap').step_over() end";
      options.desc = "Step over";
    }
    {
      mode = "n";
      key = "<leader>dr";
      action.__raw = "function() require('dap').repl.toggle() end";
      options.desc = "Toggle REPL";
    }
    {
      mode = "n";
      key = "<leader>dt";
      action.__raw = "function() require('dap').terminate() end";
      options.desc = "Terminate";
    }
    {
      mode = "n";
      key = "<leader>du";
      action.__raw = "function() require('dapui').toggle() end";
      options.desc = "Toggle DAP UI";
    }
    {
      mode = "n";
      key = "<leader>td";
      action.__raw = "function() require('neotest').run.run({ strategy = 'dap' }) end";
      options.desc = "Debug nearest test";
    }
    {
      mode = "n";
      key = "<leader>tr";
      action.__raw = "function() require('neotest').run.run() end";
      options.desc = "Run nearest test";
    }
    {
      mode = "n";
      key = "<leader>tf";
      action.__raw = "function() require('neotest').run.run(vim.fn.expand('%')) end";
      options.desc = "Run test file";
    }
    {
      mode = "n";
      key = "<leader>ta";
      action.__raw = "function() require('neotest').run.run(vim.uv.cwd()) end";
      options.desc = "Run all tests";
    }
    {
      mode = "n";
      key = "<leader>tl";
      action.__raw = "function() require('neotest').run.run_last() end";
      options.desc = "Run last test";
    }
    {
      mode = "n";
      key = "<leader>to";
      action.__raw = "function() require('neotest').output.open({ enter = true, auto_close = true }) end";
      options.desc = "Show test output";
    }
    {
      mode = "n";
      key = "<leader>ts";
      action.__raw = "function() require('neotest').summary.toggle() end";
      options.desc = "Toggle test summary";
    }
    {
      mode = "n";
      key = "<leader>tS";
      action.__raw = "function() require('neotest').run.stop() end";
      options.desc = "Stop test";
    }
    {
      mode = "n";
      key = "<leader>tw";
      action.__raw = "function() require('neotest').watch.toggle(vim.fn.expand('%')) end";
      options.desc = "Toggle test watch";
    }
  ]
  ++ map harpoonSelect harpoonSlots
  ++ map harpoonSet harpoonSlots;
}
