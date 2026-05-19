{ pkgs, vars, ... }:
{
  programs = {
    eza = {
      enable = true;
      icons = "always";
      git = true;
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = [ "--cmd cd" ];
    };

    zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      enableCompletion = true;

      history = {
        path = "${vars.home}/.local/state/zsh/history";
        size = 10000;
        save = 10000;
        ignoreDups = true;
        ignoreAllDups = true;
        ignoreSpace = true;
      };

      historySubstringSearch = {
        enable = true;
        searchUpKey = "^p";
        searchDownKey = "^n";
      };

      shellAliases = {
        c = "clear";
        ls = "eza";
        ll = "eza -lah";
        lt = "eza --tree";
        lg = "lazygit";
        v = "nvim";
        cat = "bat";
      };

      plugins = [
        {
          name = "fzf-tab";
          src = pkgs.zsh-fzf-tab;
          file = "share/zsh/plugins/zsh-fzf-tab/zsh-fzf-tab.plugin.zsh";
        }
        {
          name = "vi-mode";
          src = pkgs.zsh-vi-mode;
          file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
        }
      ];

      initContent = ''
        zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
        zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
        zstyle ':completion:*' menu no
        zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --icons=always --color=always $realpath'
        zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza --icons=always --color=always $realpath'

        killport() {
          local pid
          pid=$(lsof -t -i tcp:"$1")
          if [[ -n "$pid" ]]; then
            kill -9 "$pid" && print "Killed PID $pid on port $1"
          else
            print "No process found on port $1"
          fi
        }

        mkcd() {
          mkdir -p "$1" && cd "$1"
        }

        zvm_after_init_commands+=('eval "$(fzf --zsh)"')
      '';
    };

    starship.enable = true;
  };
}
