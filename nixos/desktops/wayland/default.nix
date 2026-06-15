{
  pkgs,
  vars,
  lib,
  ...
}:
{
  imports = [
    ./hyprland.nix
    ./noctalia.nix
  ];

  programs.regreet = {
    enable = true;
    settings.background = lib.mkForce { };
  };

  environment = {
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      ELECTRON_OZONE_PLATFORM_HINT = "wayland";
      QT_QPA_PLATFORM = "wayland;xcb";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      GDK_BACKEND = "wayland,x11";
      SDL_VIDEODRIVER = "wayland";
      CLUTTER_BACKEND = "wayland";
      XDG_SESSION_TYPE = "wayland";
      XCURSOR_SIZE = "24";
      XCURSOR_THEME = "catppuccin-frappe-blue-cursors";
      GDK_SCALE = vars.hyprland.scale;
    };

    systemPackages = with pkgs; [
      wl-clipboard
      wlr-randr
    ];
  };

  hardware.graphics.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = [ "gtk" ];
  };
}
