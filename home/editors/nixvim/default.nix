{ pkgs, ... }:
{
  imports = [
    ./keymaps.nix
    ./plugins/completion.nix
    ./plugins/editor.nix
    ./plugins/formatting.nix
    ./plugins/linting.nix
    ./plugins/lsp.nix
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withNodeJs = true;
    withPython3 = true;

    globals = {
      mapleader = " ";
      maplocalleader = " ";
      have_nerd_font = true;
    };

    extraConfigLuaPre = ''
      _G.KaneProjectRoot = function(bufnr)
        bufnr = bufnr or 0
        return vim.fs.root(bufnr, { ".git", "flake.nix", "package.json", "composer.json" }) or vim.fn.getcwd()
      end

      _G.KanePrettierArgs = function(ctx)
        local filename = ctx and ctx.filename or vim.api.nvim_buf_get_name(0)
        local start = filename ~= "" and vim.fs.dirname(filename) or vim.fn.getcwd()
        local config = vim.fs.find({
          ".prettierrc",
          ".prettierrc.json",
          ".prettierrc.json5",
          ".prettierrc.yaml",
          ".prettierrc.yml",
          ".prettierrc.toml",
          ".prettierrc.js",
          ".prettierrc.cjs",
          ".prettierrc.mjs",
          "prettier.config.js",
          "prettier.config.cjs",
          "prettier.config.mjs",
        }, { path = start, upward = true })[1]

        if config then
          return {}
        end

        return { "--arrow-parens", "avoid", "--print-width", "100", "--trailing-comma", "none" }
      end

      _G.KaneToggleInlayHints = function()
        local bufnr = vim.api.nvim_get_current_buf()
        local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
        vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
      end

      _G.KaneLint = function()
        local js_like = {
          javascript = true,
          javascriptreact = true,
          typescript = true,
          typescriptreact = true,
          vue = true,
          svelte = true,
        }

        if js_like[vim.bo.filetype] then
          local filename = vim.api.nvim_buf_get_name(0)
          local start = filename ~= "" and vim.fs.dirname(filename) or vim.fn.getcwd()
          local eslint_config = vim.fs.find({
            "eslint.config.js",
            "eslint.config.mjs",
            "eslint.config.cjs",
            ".eslintrc",
            ".eslintrc.js",
            ".eslintrc.cjs",
            ".eslintrc.json",
          }, { path = start, upward = true })[1]

          if not eslint_config then
            return
          end
        end

        local lint = require("lint")
        local names = lint.linters_by_ft[vim.bo.filetype] or {}
        local available = {}

        for _, name in ipairs(names) do
          local linter = lint.linters[name]
          local command = type(linter) == "table" and linter.cmd or nil

          if type(command) == "function" then
            command = command()
          end

          if type(command) == "string" and vim.fn.executable(command) == 1 then
            table.insert(available, name)
          end
        end

        if #available == 0 then
          return
        end

        lint.try_lint(available)
      end
    '';

    opts = {
      autowrite = true; # Enable auto write
      clipboard.__raw = ''vim.env.SSH_CONNECTION and "" or "unnamedplus"''; # Sync with system clipboard
      completeopt = [
        "menu"
        "menuone"
        "noselect"
      ];
      conceallevel = 2; # Hide * markup for bold and italic, but not markers with substitutions
      confirm = true; # Confirm to save changes before exiting modified buffer
      cursorline = true; # Enable highlighting of the current line
      expandtab = true; # Use spaces instead of tabs
      fillchars = {
        foldopen = "";
        foldclose = "";
        fold = " ";
        foldsep = " ";
        diff = "╱";
        eob = " ";
      };
      foldlevel = 99;
      foldmethod = "indent";
      foldtext = "";
      grepformat = "%f:%l:%c:%m";
      grepprg = "rg #vimgrep";
      ignorecase = true;
      inccommand = "nosplit"; # preview incremental substitute
      jumpoptions = "view";
      laststatus = 3; # global statusline
      linebreak = true; # Wrap lines at convenient points
      list = true; # Show some invisible characters (tabs...
      listchars = {
        tab = "» ";
        trail = "·";
        nbsp = "␣";
        extends = "›";
        precedes = "‹";
      };
      mouse = "a"; # Enable mouse mode
      number = true; # Print line number
      pumblend = 10; # Popup blend
      pumheight = 10; # Maximum number of entries in a popup
      relativenumber = true; # Relative line numbers
      ruler = false; # Disable the default ruler
      scrolloff = 4; # Lines of context
      sessionoptions = [
        "buffers"
        "curdir"
        "tabpages"
        "winsize"
        "help"
        "globals"
        "skiprtp"
        "folds"
      ];
      shortmess = "filnxtToOFWIcC";
      # This depends on LazyVim's Lua module, which this config does not load.
      # statuscolumn = "%!v:lua.LazyVim.statuscolumn()";
      shiftround = true; # Round indent
      shiftwidth = 2; # Size of an indent
      showmode = false; # Dont show mode since we have a statusline
      sidescrolloff = 8; # Columns of context
      signcolumn = "yes"; # Always show the signcolumn, otherwise it would shift the text each time
      smartcase = true; # Don't ignore case with capitals
      smartindent = true; # Insert indents automatically
      smoothscroll = true;
      spelllang = [ "en" ];
      splitbelow = true; # Put new windows below current
      splitkeep = "screen";
      splitright = true; # Put new windows right of current
      tabstop = 2; # Number of spaces tabs count for
      termguicolors = true; # True color support
      timeoutlen = 300; # Lower than default (1000) to quickly trigger which-key
      undofile = true;
      undolevels = 10000;
      updatetime = 200; # Save swap file and trigger CursorHold
      virtualedit = "block"; # Allow cursor to move where there is no text in visual block mode
      wildmode = "longest:full,full"; # Command-line completion mode
      winminwidth = 5; # Minimum window width
      wrap = false; # Disable line wrap
    };

    diagnostic.settings = {
      virtual_text = false;
      severity_sort = true;
      float = {
        border = "rounded";
        source = "if_many";
      };
    };

    highlightOverride = {
      LineNr.bg = "NONE";
      CursorLineNr.bg = "NONE";
      SignColumn.bg = "NONE";
      FoldColumn.bg = "NONE";
    };

    extraPlugins = with pkgs.vimPlugins; [
      vim-tmux-navigator
    ];

    extraPackages = with pkgs; [
      clang-tools
      cmake-language-server
      eslint_d
      fd
      fzf
      intelephense
      lua-language-server
      nixfmt
      phpactor
      phpPackages.php-cs-fixer
      prettierd
      ripgrep
      stylua
      tailwindcss-language-server
      typescript-language-server
      vscode-langservers-extracted
    ];
  };
}
