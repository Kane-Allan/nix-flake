{ pkgs, ... }:
{
  programs.chromium = {
    enable = true;
    package = pkgs.brave;
    commandLineArgs = [
      "--ozone-platform-hint=auto"
      "--enable-features=TouchpadOverscrollHistoryNavigation,WebContentsForceDark"
      "--force-dark-mode"
    ];
    extensions = [
      { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # uBlock Origin
      { id = "nngceckbapebfimnlniiiahkandclblb"; } # Bitwarden
      { id = "eimadpbcbfnmbkopoojfekhnkhdbieeh"; } # Dark Reader
      { id = "hfjbmagddngcpeloejdejnfgbamkjaeg"; } # Vimium C
      # { id = "eimadpbcbfnmbkopoojfekhnkhdbieeh"; } # Dark reader
    ];
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = [ "brave-browser.desktop" ];
      "x-scheme-handler/http" = [ "brave-browser.desktop" ];
      "x-scheme-handler/https" = [ "brave-browser.desktop" ];
      "x-scheme-handler/about" = [ "brave-browser.desktop" ];
      "x-scheme-handler/unknown" = [ "brave-browser.desktop" ];
    };
  };
}
