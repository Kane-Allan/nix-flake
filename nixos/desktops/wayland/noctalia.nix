{
  config,
  inputs,
  vars,
  pkgs,
  lib,
  ...
}:
let
  colors = config.lib.stylix.colors;
  hex = color: "#${color}";
  noctaliaPackage = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;

  palette = {
    dark = {
      mPrimary = hex colors.base0D;
      mOnPrimary = hex colors.base00;
      mSecondary = hex colors.base0E;
      mOnSecondary = hex colors.base00;
      mTertiary = hex colors.base0C;
      mOnTertiary = hex colors.base00;
      mError = hex colors.base08;
      mOnError = hex colors.base00;
      mSurface = hex colors.base00;
      mOnSurface = hex colors.base05;
      mSurfaceVariant = hex colors.base01;
      mOnSurfaceVariant = hex colors.base04;
      mOutline = hex colors.base03;
      mShadow = hex colors.base00;
      mHover = hex colors.base02;
      mOnHover = hex colors.base05;

      terminal = {
        background = hex colors.base00;
        foreground = hex colors.base05;
        cursor = hex colors.base05;
        cursorText = hex colors.base00;
        selectionBg = hex colors.base02;
        selectionFg = hex colors.base05;

        normal = {
          black = hex colors.base00;
          red = hex colors.base08;
          green = hex colors.base0B;
          yellow = hex colors.base0A;
          blue = hex colors.base0D;
          magenta = hex colors.base0E;
          cyan = hex colors.base0C;
          white = hex colors.base05;
        };

        bright = {
          black = hex colors.base03;
          red = hex colors.base08;
          green = hex colors.base0B;
          yellow = hex colors.base0A;
          blue = hex colors.base0D;
          magenta = hex colors.base0E;
          cyan = hex colors.base0C;
          white = hex colors.base07;
        };
      };
    };
  };

  bongocatSettings = {
    audio_spectrum = true;
    tappy_mode = true;
    type = "noctalia/bongocat:cat";
  }
  //
    lib.optionalAttrs
      (vars ? noctalia && vars.noctalia ? bongocat && vars.noctalia.bongocat ? inputDevice)
      {
        input_device = vars.noctalia.bongocat.inputDevice;
      };
in
{
  environment.systemPackages = with pkgs; [
    evtest
  ];

  home-manager.users.${vars.user} = {
    imports = [ inputs.noctalia.homeModules.default ];

    programs.noctalia = {
      enable = true;
      package = noctaliaPackage;
      systemd.enable = true;

      customPalettes.stylix = palette;

      settings = {
        shell = {
          font_family = config.stylix.fonts.sansSerif.name;
          launch_apps_as_systemd_services = true;
          panel.control_center_placement = "floating";
        };

        bar.default = {
          start = [
            "launcher"
            "taskbar"
          ];
          center = [
            "clock"
            "cat"
          ];
          end = [
            "cpu"
            "ram"
            "notifications"
            "clipboard"
            "volume"
            "brightness"
            "battery"
          ];

          margin_edge = 0;
          margin_ends = 0;
          widget_spacing = 12;
        };

        notification.position = "top_center";

        plugins.enabled = [ "noctalia/bongocat" ];

        widget = {
          cat = bongocatSettings;

          network.show_label = false;

          taskbar = {
            group_by_workspace = true;
            group_single_icon_per_app = true;
          };

          ram = {
            display = "text";
            stat = "ram_pct";
          };

          cpu.display = "text";
        };

        theme = {
          mode = "dark";
          source = "custom";
          custom_palette = "stylix";
        };
      };
    };
  };
}
