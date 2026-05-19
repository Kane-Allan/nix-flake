{
  ...
}:
{
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      window-decoration = true;
      window-padding-x = 4;
      window-padding-y = 4;
      cursor-style = "bar";
      cursor-style-blink = false;
      copy-on-select = "clipboard";
      term = "xterm-256color";
      keybind = [ ''shift+enter=text:\x1b[13;2u'' ];
    };
  };
}
