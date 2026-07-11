{
  inputs,
  vars,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    evtest
  ];

  home-manager.users.${vars.user} = {
    imports = [ inputs.noctalia.homeModules.default ];

    programs.noctalia = {
      enable = true;
      systemd.enable = true;

      settings = {
        shell = {
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
            "control-center"
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
          radius = 0;
        };

        notification.position = "top_center";

        lockscreen.enabled = true;

        idle = {
          behavior_order = [
            "lock"
            "screen-off"
            "lock-and-suspend"
          ];

          behavior = {
            lock = {
              action = "lock";
              enabled = true;
              timeout = 600.0;
            };

            lock-and-suspend = {
              action = "lock_and_suspend";
              enabled = true;
              timeout = 900.0;
            };

            screen-off = {
              action = "screen_off";
              enabled = true;
              timeout = 660.0;
            };
          };
        };

        widget = {
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
        };
      };
    };
  };
}
