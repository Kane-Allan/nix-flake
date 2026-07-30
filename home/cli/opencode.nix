{ pkgs, ... }:
{
  programs.opencode = {
    enable = true;

    settings.autoupdate = false;

    tui.attention = {
      enabled = true;
      notifications = true;
      sound = true;
    };

    extraPackages = with pkgs; [
      libnotify
    ];
  };
}
