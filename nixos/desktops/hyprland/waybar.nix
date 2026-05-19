{ pkgs, ... }:
let
  chatgptPanel = pkgs.callPackage ../../../pkgs/chatgpt-panel { };
  hyprctl = "${pkgs.hyprland}/bin/hyprctl";

  focusWindow = pkgs.writeShellScript "focus-window" ''
    #!/bin/sh

    address=$1

    # https://api.gtkd.org/gdk.c.types.GdkEventButton.button.html
    button=$2

    if [ $button -eq 1 ]; then
        # Left click: focus window
        hyprctl eval 'hl.config({ cursor = {no_warps=true} })'
        hyprctl dispatch "hl.dsp.focus({window='address:$address'})"
        hyprctl eval 'hl.config({ cursor = {no_warps=false} })'
    elif [ $button -eq 2 ]; then
        # Middle click: close window
        hyprctl dispatch "hl.dsp.window.close({window='address:$address'})"
    fi
  '';

  chatgptOverlay = pkgs.writeShellScript "waybar-chatgpt-overlay" ''
    if ${chatgptPanel}/bin/chatgpt-panelctl toggle >/dev/null 2>&1; then
      exit 0
    fi

    if ${pkgs.systemd}/bin/systemctl --user start chatgpt-panel.service >/dev/null 2>&1; then
      for _ in 1 2 3 4 5 6 7 8 9 10; do
        if ${chatgptPanel}/bin/chatgpt-panelctl show >/dev/null 2>&1; then
          exit 0
        fi
        ${pkgs.coreutils}/bin/sleep 0.1
      done
    fi

    exec ${pkgs.util-linux}/bin/setsid -f ${chatgptPanel}/bin/chatgpt-panel
  '';

  networkMenuConfig = pkgs.writeText "networkmanager-dmenu.ini" ''
    [dmenu]
    dmenu_command = ${pkgs.fuzzel}/bin/fuzzel --dmenu --prompt=Networks:
    compact = True
    list_saved = True
    wifi_icons = 󰤯󰤟󰤢󰤥󰤨

    [dmenu_passphrase]
    obscure = True

    [editor]
    gui_if_available = True
    gui = ${pkgs.networkmanagerapplet}/bin/nm-connection-editor
    terminal = ${pkgs.ghostty}/bin/ghostty -e
  '';

  networkMenu = pkgs.writeShellScript "waybar-network-menu" ''
    exec ${pkgs.networkmanager_dmenu}/bin/networkmanager_dmenu --config ${networkMenuConfig}
  '';
in
{
  programs.waybar = {
    enable = true;
    settings = {
      main = {
        layer = "top";
        position = "top";
        height = 44;
        spacing = 4;
        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "hyprland/window" ];
        modules-right = [
          "bluetooth"
          "network"
          "idle_inhibitor"

          "pulseaudio"
          "cpu"
          "memory"
          "battery"

          "custom/ai"
          "custom/notification"
          "clock"
        ];

        "hyprland/workspaces" = {
          on-click = "activate";
          on-scroll-up = "${hyprctl} dispatch 'hl.dsp.focus({ workspace = \"e+1\" })'";
          on-scroll-down = "${hyprctl} dispatch 'hl.dsp.focus({ workspace = \"e-1\" })'";
          format = "{name}  {windows}";
          format-window-separator = " ";
          window-rewrite-default = "?";
          workspace-taskbar = {
            enable = true;
            update-active-window = true;
            format = "{icon}";
            icon-size = 20;
            icon-theme = [
              "hicolor"
              "Papirus-Dark"
            ];
            on-click-window = "${focusWindow} {address} {button}";
          };
          format-icons.default = "";
        };

        "hyprland/window" = {
          max-length = 50;
        };

        clock = {
          interval = 1;
          format = "{:%H:%M:%S}";
          tooltip = true;
          tooltip-format = "{:%A, %d %B %Y}";
        };

        cpu = {
          interval = 5;
          format = " {usage}%";
        };

        memory = {
          interval = 5;
          format = " {percentage}%";
        };

        battery = {
          interval = 1;
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-icons = {
            default = [
              "󰂎"
              "󰁺"
              "󰁻"
              "󰁼"
              "󰁽"
              "󰁾"
              "󰁿"
              "󰂀"
              "󰂁"
              "󰂂"
              "󰁹"
            ];
            charging = [
              "󰢟"
              "󰢜"
              "󰂆"
              "󰂇"
              "󰂈"
              "󰢝"
              "󰂉"
              "󰢞"
              "󰂊"
              "󰂋"
              "󰂅"
            ];
          };
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = "󰖁";
          format-icons.default = [
            "󰕿"
            "󰖀"
            "󰕾"
          ];
          scroll-step = 5;
          on-click = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          on-click-right = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_SOURCE@ toggle";
          on-click-middle = "${pkgs.pavucontrol}/bin/pavucontrol";
        };

        bluetooth = {
          format = "󰂯";
          format-disabled = "󰂲";
          format-off = "󰂲";
          format-on = "󰂯";
          format-connected = "󰂱 {num_connections}";
          tooltip-format = "{controller_alias}\t{controller_address}";
          tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
          on-click = "${pkgs.blueman}/bin/blueman-manager";
          on-click-right = "${pkgs.blueman}/bin/blueman-adapters";
        };

        network = {
          interval = 5;
          format-wifi = "{icon}";
          format-ethernet = "󰈀 wired";
          format-disconnected = "󰖪 offline";
          format-disabled = "󰖪 disabled";
          format-icons = [
            "󰤯"
            "󰤟"
            "󰤢"
            "󰤥"
            "󰤨"
          ];
          tooltip-format = "{ifname}: {ipaddr}/{cidr}";
          tooltip-format-wifi = "{essid} ({signalStrength}%)\n{ifname}: {ipaddr}/{cidr}";
          tooltip-format-disconnected = "Disconnected";
          on-click = "${networkMenu}";
          on-click-right = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
        };

        idle_inhibitor = {
          format = "{icon}";
          format-icons = {
            activated = "󰅶";
            deactivated = "󰾪";
          };
          tooltip-format-activated = "Idle inhibitor active";
          tooltip-format-deactivated = "Idle inhibitor inactive";
        };

        "custom/notification" = {
          tooltip = false;
          format = "{icon} {text}";
          format-icons = {
            notification = "󰂚";
            none = "󰂜";
            dnd-notification = "󰂛";
            dnd-none = "󰪑";
            inhibited-notification = "󰂚";
            inhibited-none = "󰂜";
            dnd-inhibited-notification = "󰂛";
            dnd-inhibited-none = "󰪑";
          };
          return-type = "json";
          exec = "${pkgs.swaynotificationcenter}/bin/swaync-client -swb";
          on-click = "${pkgs.swaynotificationcenter}/bin/swaync-client -t -sw";
          on-click-right = "${pkgs.swaynotificationcenter}/bin/swaync-client -d -sw";
          escape = true;
        };

        "custom/ai" = {
          format = "󰚩 {}";
          tooltip = true;
          tooltip-format = "Toggle ChatGPT panel";
          exec = "${pkgs.coreutils}/bin/printf AI";
          interval = 3600;
          on-click = "${chatgptOverlay}";
        };
      };
    };

    style = ''
      #idle_inhibitor.activated {
        color: #a6da95;
      }

      #idle_inhibitor.deactivated {
        color: #6e738d;
      }

      #bluetooth,
      #network,
      #idle_inhibitor {
        font-size: 14pt;
      }

      #custom-ai {
        margin-right: 8px;
      }

      #pulseaudio,
      #custom-ai {
        margin-left: 10px;
        padding-left: 12px;
      }
    '';
  };
}
