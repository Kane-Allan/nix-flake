{ pkgs, ... }:
{
  stylix = {
    enable = true;
    polarity = "dark";

    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-frappe.yaml";

    cursor = {
      package = pkgs.catppuccin-cursors.frappeBlue;
      name = "catppuccin-frappe-blue-cursors";
      size = 24;
    };

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font Mono";
      };
      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };
    };

    image = ../../assets/wallpaper.png;
  };
}
