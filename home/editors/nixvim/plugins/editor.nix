{
  programs.nixvim.plugins = {
    colorizer = {
      enable = true;
      settings = {
        filetypes = [ "*" ];
        user_default_options = {
          css = true;
          tailwind = "both";
          mode = "virtualtext";
          names = false;
          virtualtext = "■ ";
        };
      };
    };

    comment.enable = true;
    fzf-lua.enable = true;
    gitsigns.enable = true;
    harpoon.enable = true;
    nvim-autopairs.enable = true;
    nvim-surround.enable = true;
    render-markdown.enable = true;
    sleuth.enable = true;
    todo-comments.enable = true;
    trouble.enable = true;
    web-devicons.enable = true;

    notify = {
      enable = true;
      settings = {
        timeout = 8000;
        render = "wrapped-compact";
      };
    };

    which-key = {
      enable = true;
      settings = {
        delay = 250;
        spec = [
          {
            __unkeyed-1 = "<leader>c";
            group = "Code";
          }
          {
            __unkeyed-1 = "<leader>f";
            group = "Find";
          }
          {
            __unkeyed-1 = "<leader>g";
            group = "Git";
          }
          {
            __unkeyed-1 = "<leader>gh";
            group = "Hunks";
          }
          {
            __unkeyed-1 = "<leader>h";
            group = "Harpoon";
          }
          {
            __unkeyed-1 = "<leader>s";
            group = "Search";
          }
          {
            __unkeyed-1 = "<leader>sn";
            group = "Notifications";
          }
          {
            __unkeyed-1 = "<leader>u";
            group = "UI";
          }
          {
            __unkeyed-1 = "<leader>x";
            group = "Diagnostics";
          }
        ];
      };
    };

    noice = {
      enable = true;
      settings = {
        lsp.override = {
          "vim.lsp.util.convert_input_to_markdown_lines" = true;
          "vim.lsp.util.stylize_markdown" = true;
          "cmp.entry.get_documentation" = true;
        };
        notify = {
          enabled = true;
          view = "notify";
        };
        presets = {
          bottom_search = true;
          command_palette = true;
          long_message_to_split = true;
        };
        routes = [
          {
            filter = {
              event = "msg_show";
              any = [
                { find = "%d+L, %d+B"; }
                { find = "; after #%d+"; }
                { find = "; before #%d+"; }
              ];
            };
            view = "mini";
          }
        ];
      };
    };

    treesitter = {
      enable = true;
      highlight.enable = true;
      indent.enable = true;
    };

    treesitter-textobjects.enable = true;

    neo-tree = {
      enable = true;
      settings = {
        sources = [
          "filesystem"
          "buffers"
          "git_status"
        ];
        open_files_do_not_replace_types = [
          "terminal"
          "Trouble"
          "trouble"
          "qf"
        ];
        filesystem = {
          bind_to_cwd = false;
          follow_current_file.enabled = true;
          use_libuv_file_watcher = true;
          filtered_items = {
            visible = true;
            hide_dotfiles = false;
            hide_gitignored = false;
          };
        };
        window.mappings = {
          l = "open";
          h = "close_node";
          "<space>" = "none";
        };
      };
    };

    lualine = {
      enable = true;
      settings.options = {
        globalstatus = true;
        component_separators = "";
        section_separators = {
          left = "";
          right = "";
        };
      };
    };
  };
}
