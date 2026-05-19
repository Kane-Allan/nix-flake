{ pkgs, ... }:
{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "yy";
    settings = {
      mgr = {
        show_hidden = false;
        show_symlink = true;
        sort_by = "alphabetical";
        sort_sensitive = false;
        sort_reverse = false;
        sort_dir_first = true;
      };

      preview = {
        tab_size = 2;
        max_width = 600;
        max_height = 900;
      };

      tasks = {
        micro_workers = 10;
        macro_workers = 25;
        bizarre_retry = 5;
      };

      opener = {
        edit = [
          {
            run = "nvim \"$@\"";
            block = true;
            for = "unix";
          }
        ];
      };
    };
    keymap = {
      mgr.prepend_keymap = [
        {
          on = "g h";
          run = "cd ~";
          desc = "Go home";
        }
        {
          on = "g c";
          run = "cd ~/.config";
          desc = "Go to ~/.config";
        }
        {
          on = "g d";
          run = "cd ~/Downloads";
          desc = "Go to Downloads";
        }
        {
          on = "R";
          run = "bulk-rename";
          desc = "Bulk rename";
        }
      ];
    };
  };

  home.packages = with pkgs; [
    ffmpegthumbnailer
    poppler
    resvg
    unar
  ];
}
