{ lib, ... }:
{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = lib.mkForce "JetBrainsMono Nerd Font Mono:size=16";
        terminal = "ghostty";
        prompt = "Search: ";
        layer = "overlay";
        width = 64;
        lines = 12;
        horizontal-pad = 24;
        vertical-pad = 16;
        inner-pad = 10;
        image-size-ratio = 0.35;
        icon-theme = "Papirus-Dark";
      };

      border = {
        width = 2;
        radius = 10;
      };
    };
  };
}
