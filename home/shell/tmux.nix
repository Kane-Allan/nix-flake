{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    clock24 = true;
    mouse = true;
    prefix = "C-Space";
    keyMode = "vi";
    terminal = "tmux-256color";
    baseIndex = 1;
    shell = "${pkgs.zsh}/bin/zsh";
    historyLimit = 10000;
    sensibleOnTop = true;

    plugins = with pkgs.tmuxPlugins; [
      yank
      vim-tmux-navigator
      catppuccin
      battery
      cpu
    ];
    extraConfig = ''
      unbind C-b
      bind C-Space send-prefix

      bind v split-window -h -c "#{pane_current_path}"
      bind s split-window -v -c "#{pane_current_path}"
      unbind '"'
      unbind %
      bind f resize-pane -Z
      bind C-r rotate-window

      set -g extended-keys on
      set -g renumber-windows on
      set -g allow-passthrough on
      set -ga update-environment TERM
      set -ga update-environment TERM_PROGRAM
      set -as terminal-features ',*:RGB'
      set -as terminal-overrides ',xterm-256color:RGB'

      set -g @catppuccin_flavor 'macchiato'
      # set -g @catppuccin_window_status_style 'rounded'

      set -g status-left ""
      set -g status-right "#{E:@catppuccin_status_application}"
    '';
  };
}
