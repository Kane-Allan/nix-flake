{ config, pkgs, ... }:
{
  gtk = {
    enable = true;
    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
      gtk-decoration-layout = "menu:";
      gtk-recent-files-enabled = false;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.theme = config.gtk.theme;
  };
}
