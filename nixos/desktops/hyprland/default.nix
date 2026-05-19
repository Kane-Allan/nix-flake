{
  config,
  pkgs,
  vars,
  lib,
  ...
}:
{
  programs.regreet.enable = true;

  security.pam.services.hyprlock = { };

  services.upower = {
    enable = true;
    usePercentageForPolicy = true;
    percentageLow = 20;
    percentageCritical = 10;
    percentageAction = 5;
  };

  services.udev.packages = [
    pkgs.brightnessctl
    pkgs.swayosd
  ];

  environment = {
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      ELECTRON_OZONE_PLATFORM_HINT = "wayland";
      QT_QPA_PLATFORM = "wayland;xcb";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      GDK_BACKEND = "wayland,x11";
      SDL_VIDEODRIVER = "wayland";
      CLUTTER_BACKEND = "wayland";
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
      XDG_SESSION_DESKTOP = "Hyprland";
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

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-hyprland
    ];
    config.common.default = [
      "hyprland"
      "gtk"
    ];
  };

  home-manager.users.${vars.user} =
    let
      monitor = "eDP-1";
      monitorMode = if vars.hyprland.resolution == "" then "preferred" else vars.hyprland.resolution;
      monitor_config = "${monitor},${monitorMode},0x0,${vars.hyprland.scale}";
      chatgptPanel = pkgs.callPackage ../../../pkgs/chatgpt-panel { };
      lockCommand = "${pkgs.procps}/bin/pgrep -x hyprlock >/dev/null || ${pkgs.hyprlock}/bin/hyprlock --grace 5";
      keyboardBacklight = pkgs.writeShellScript "keyboard-backlight" ''
        set -eu

        device="platform::kbd_backlight"
        current=$(${pkgs.brightnessctl}/bin/brightnessctl --device="$device" get 2>/dev/null || printf 0)
        max=$(${pkgs.brightnessctl}/bin/brightnessctl --device="$device" max 2>/dev/null || printf 2)

        case "''${1:-cycle}" in
          cycle)
            next=$((current + 1))
            if [ "$next" -gt "$max" ]; then
              next=0
            fi
            ;;
          up)
            next=$((current + 1))
            if [ "$next" -gt "$max" ]; then
              next="$max"
            fi
            ;;
          down)
            next=$((current - 1))
            if [ "$next" -lt 0 ]; then
              next=0
            fi
            ;;
          off)
            next=0
            ;;
          full)
            next="$max"
            ;;
          *)
            exit 2
            ;;
        esac

        exec ${pkgs.brightnessctl}/bin/brightnessctl --device="$device" set "$next"
      '';
      colors = config.lib.stylix.colors;
      rgb = color: "rgb(${color})";
      rgba = color: alpha: "rgba(${color}${alpha})";
      toLua = lib.generators.toLua { };
      lua = lib.generators.mkLuaInline;
      mkBind = keys: dispatcher: {
        _args = [
          keys
          (lua dispatcher)
        ];
      };
      mkBindWith = keys: dispatcher: opts: {
        _args = [
          keys
          (lua dispatcher)
          opts
        ];
      };
      mkExecBind = keys: command: mkBind keys "hl.dsp.exec_cmd(${toLua command})";
      mkExecBindWith =
        keys: command: opts:
        mkBindWith keys "hl.dsp.exec_cmd(${toLua command})" opts;

      tmuxTerminal = pkgs.writeShellScript "ghostty-tmux" ''
        exec ${pkgs.ghostty}/bin/ghostty -e ${pkgs.zsh}/bin/zsh -l -c '${pkgs.tmux}/bin/tmux attach || ${pkgs.tmux}/bin/tmux'
      '';

      yaziTerminal = pkgs.writeShellScript "ghostty-yazi" ''
        exec ${pkgs.ghostty}/bin/ghostty --title=yazi --class=yazi -e ${pkgs.yazi}/bin/yazi
      '';

      clamshell = pkgs.writeShellScript "hypr-clamshell" ''
        if [[ $(${pkgs.hyprland}/bin/hyprctl monitors 2>/dev/null | ${pkgs.ripgrep}/bin/rg "\sDP-[0-9]+") ]]; then
          if [[ $1 == "open" ]]; then
            ${pkgs.hyprland}/bin/hyprctl keyword monitor ${monitor_config}
            sleep 0.5
            ${pkgs.hyprland}/bin/hyprctl dispatch dpms on ${monitor}
          else
            ${pkgs.hyprland}/bin/hyprctl keyword monitor "${monitor},disable"
          fi
        else
          if [[ $1 != "open" ]]; then
            ${lockCommand}
          fi
        fi
      '';
    in
    {
      imports = [
        ./fuzzel.nix
        ./swaync.nix
        ./waybar.nix
      ];

      home.packages = with pkgs; [
        brightnessctl
        chatgptPanel
        networkmanager_dmenu
      ];

      systemd.user.services.chatgpt-panel = {
        Unit = {
          Description = "ChatGPT layer-shell panel";
        };

        Service = {
          ExecStart = "${chatgptPanel}/bin/chatgpt-panel";
          Restart = "on-failure";
          RestartSec = "2s";
        };
      };

      services = {
        poweralertd = {
          enable = true;
          extraArgs = [ "-S" ];
        };

        swayosd.enable = true;
      };

      services.hypridle = {
        enable = true;
        settings = {
          general = {
            lock_cmd = lockCommand;
            ignore_dbus_inhibit = false;
            before_sleep_cmd = "${pkgs.systemd}/bin/loginctl lock-session";
            after_sleep_cmd = "hyprctl dispatch dpms on";
          };

          listener = [
            {
              # suspend after 30 mins; before_sleep_cmd locks first.
              timeout = 1800;
              on-timeout = "${pkgs.systemd}/bin/systemctl suspend";
            }
            {
              # turn screen off after 15 mins
              timeout = 900;
              on-timeout = "hyprctl dispatch dpms off";
              on-resume = "hyprctl dispatch dpms on";
            }
          ];
        };
      };

      programs.hyprlock = {
        enable = true;
        settings = {
          general = {
            hide_cursor = true;
          };
        };
      };

      wayland.windowManager.hyprland = {
        enable = true;
        systemd.enable = false;
        xwayland.enable = true;

        configType = "lua";

        settings = lib.mkForce {
          monitor = [
            {
              output = monitor;
              mode = monitorMode;
              position = "0x0";
              scale = vars.hyprland.scale;
            }
            {
              output = "";
              mode = "preferred";
              position = "auto";
              scale = 1;
            }
          ];

          on = {
            _args = [
              "hyprland.start"
              (lua ''
                function()
                  hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
                  hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
                  hl.exec_cmd("${pkgs.waybar}/bin/waybar")
                end
              '')
            ];
          };

          config = {
            input = {
              kb_layout = "gb";
              kb_options = "caps:ctrl_modifier";
              accel_profile = "flat";
              follow_mouse = 1;
              touchpad = {
                disable_while_typing = false;
                natural_scroll = true;
                scroll_factor = 0.2;
                tap_to_click = true;
                middle_button_emulation = true;
              };
            };

            general = {
              gaps_in = 4;
              gaps_out = 8;
              border_size = 2;
              layout = "dwindle";
              resize_on_border = true;
              "col.active_border" = rgb colors.base0D;
              "col.inactive_border" = rgb colors.base03;
            };

            decoration = {
              rounding = 6;

              blur = {
                enabled = true;
                size = 4;
                passes = 1;
                new_optimizations = true;
              };

              shadow = {
                enabled = true;
                range = 12;
                render_power = 2;
                color = rgba colors.base00 "99";
              };

              active_opacity = 1.0;
              inactive_opacity = 0.96;

              dim_inactive = false;
            };

            animations.enabled = true;

            dwindle = {
              force_split = 2;
              preserve_split = true;
            };

            group = {
              "col.border_inactive" = rgb colors.base03;
              "col.border_active" = rgb colors.base0D;
              "col.border_locked_active" = rgb colors.base0C;

              groupbar = {
                text_color = rgb colors.base05;
                "col.active" = rgb colors.base0D;
                "col.inactive" = rgb colors.base03;
              };
            };

            misc = {
              force_default_wallpaper = 0;
              disable_hyprland_logo = true;
              mouse_move_enables_dpms = true;
              key_press_enables_dpms = true;
              background_color = rgb colors.base00;
            };

            xwayland.force_zero_scaling = true;
          };

          curve = [
            {
              _args = [
                "linear"
                {
                  type = "bezier";
                  points = [
                    [
                      0
                      0
                    ]
                    [
                      1
                      1
                    ]
                  ];
                }
              ];
            }
            {
              _args = [
                "md3_standard"
                {
                  type = "bezier";
                  points = [
                    [
                      0.2
                      0
                    ]
                    [
                      0
                      1
                    ]
                  ];
                }
              ];
            }
            {
              _args = [
                "md3_decel"
                {
                  type = "bezier";
                  points = [
                    [
                      0.05
                      0.7
                    ]
                    [
                      0.1
                      1
                    ]
                  ];
                }
              ];
            }
            {
              _args = [
                "md3_accel"
                {
                  type = "bezier";
                  points = [
                    [
                      0.3
                      0
                    ]
                    [
                      0.8
                      0.15
                    ]
                  ];
                }
              ];
            }
            {
              _args = [
                "overshot"
                {
                  type = "bezier";
                  points = [
                    [
                      0.05
                      0.9
                    ]
                    [
                      0.1
                      1.1
                    ]
                  ];
                }
              ];
            }
            {
              _args = [
                "crazyshot"
                {
                  type = "bezier";
                  points = [
                    [
                      0.1
                      1.5
                    ]
                    [
                      0.76
                      0.92
                    ]
                  ];
                }
              ];
            }
            {
              _args = [
                "hyprnostretch"
                {
                  type = "bezier";
                  points = [
                    [
                      0.05
                      0.9
                    ]
                    [
                      0.1
                      1.0
                    ]
                  ];
                }
              ];
            }
            {
              _args = [
                "fluent_decel"
                {
                  type = "bezier";
                  points = [
                    [
                      0.1
                      1
                    ]
                    [
                      0
                      1
                    ]
                  ];
                }
              ];
            }
            {
              _args = [
                "easeInOutCirc"
                {
                  type = "bezier";
                  points = [
                    [
                      0.85
                      0
                    ]
                    [
                      0.15
                      1
                    ]
                  ];
                }
              ];
            }
            {
              _args = [
                "easeOutCirc"
                {
                  type = "bezier";
                  points = [
                    [
                      0
                      0.55
                    ]
                    [
                      0.45
                      1
                    ]
                  ];
                }
              ];
            }
            {
              _args = [
                "easeOutExpo"
                {
                  type = "bezier";
                  points = [
                    [
                      0.16
                      1
                    ]
                    [
                      0.3
                      1
                    ]
                  ];
                }
              ];
            }
          ];

          animation = [
            {
              leaf = "windows";
              enabled = true;
              speed = 3;
              bezier = "md3_decel";
              style = "popin 60%";
            }
            {
              leaf = "border";
              enabled = true;
              speed = 10;
              bezier = "default";
            }
            {
              leaf = "fade";
              enabled = true;
              speed = 2.5;
              bezier = "md3_decel";
            }
            {
              leaf = "workspaces";
              enabled = true;
              speed = 3.5;
              bezier = "easeOutExpo";
              style = "slide";
            }
            {
              leaf = "specialWorkspace";
              enabled = true;
              speed = 3;
              bezier = "md3_decel";
              style = "slidevert";
            }
          ];

          window_rule = [
            {
              match.class = "^(pavucontrol)$";
              float = true;
            }
            {
              match.class = "^(yazi)$";
              float = true;
            }
            {
              match.class = "^(yazi)$";
              size = [
                1000
                700
              ];
            }
            {
              match.class = "^(yazi)$";
              center = true;
            }
            {
              match.class = ".*";
              suppress_event = "maximize";
            }
            {
              match = {
                class = "^(net-runelite-client-RuneLite)$";
                title = "^(win0)$";
              };
              no_initial_focus = true;
            }
            {
              match = {
                class = "net-runelite-client-RuneLite";
                title = "Picture in Picture";
                xwayland = true;
              };

              float = true;
              pin = true;
              size = [
                480
                270
              ];
              move = [
                "monitor_w - window_w - 20"
                "monitor_h - window_h - 20"
              ];

              no_initial_focus = true;
              no_focus = true;
              no_follow_mouse = true;
              focus_on_activate = false;
              decorate = false;
            }
          ];

          bind = [
            (mkExecBind "SUPER + Return" tmuxTerminal)
            (mkExecBind "SUPER + SHIFT + Return" "${pkgs.brave}/bin/brave")
            (mkExecBind "SUPER + Space" "${pkgs.fuzzel}/bin/fuzzel")
            (mkExecBind "SUPER + E" yaziTerminal)

            (mkBind "SUPER + Q" "hl.dsp.window.close()")
            (mkBind "SUPER + SHIFT + Q" "hl.dsp.exit()")
            (mkBind "SUPER + T" ''hl.dsp.window.float({ action = "toggle" })'')
            (mkBind "SUPER + F" ''hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" })'')

            (mkBind "SUPER + H" ''hl.dsp.focus({ direction = "l" })'')
            (mkBind "SUPER + J" ''hl.dsp.focus({ direction = "d" })'')
            (mkBind "SUPER + K" ''hl.dsp.focus({ direction = "u" })'')
            (mkBind "SUPER + L" ''hl.dsp.focus({ direction = "r" })'')

            (mkBind "SUPER + SHIFT + H" ''hl.dsp.window.move({ direction = "l" })'')
            (mkBind "SUPER + SHIFT + J" ''hl.dsp.window.move({ direction = "d" })'')
            (mkBind "SUPER + SHIFT + K" ''hl.dsp.window.move({ direction = "u" })'')
            (mkBind "SUPER + SHIFT + L" ''hl.dsp.window.move({ direction = "r" })'')

            (mkBind "SUPER + left" "hl.dsp.window.resize({ x = -30, y = 0, relative = true })")
            (mkBind "SUPER + right" "hl.dsp.window.resize({ x = 30, y = 0, relative = true })")
            (mkBind "SUPER + up" "hl.dsp.window.resize({ x = 0, y = -30, relative = true })")
            (mkBind "SUPER + down" "hl.dsp.window.resize({ x = 0, y = 30, relative = true })")
          ]
          ++ (map
            (
              workspace:
              mkBind "SUPER + ${toString workspace}" "hl.dsp.focus({ workspace = ${toString workspace} })"
            )
            [
              1
              2
              3
              4
              5
              6
              7
              8
              9
            ]
          )
          ++ (map
            (
              workspace:
              mkBind "SUPER + SHIFT + ${toString workspace}" "hl.dsp.window.move({ workspace = ${toString workspace} })"
            )
            [
              1
              2
              3
              4
              5
              6
              7
              8
              9
            ]
          )
          ++ [
            (mkExecBind "SUPER + S" "${pkgs.systemd}/bin/systemctl suspend")
            (mkExecBind "SUPER + CTRL + L" lockCommand)
            (mkExecBind "SUPER + B" "${keyboardBacklight} cycle")
            (mkExecBind "SUPER + SHIFT + B" "${keyboardBacklight} off")
            (mkExecBind "SUPER + CTRL + B" "${keyboardBacklight} full")

            (mkExecBind "Print" "${pkgs.hyprshot}/bin/hyprshot -m window")
            (mkExecBind "CTRL + Print" "${pkgs.hyprshot}/bin/hyprshot -m region")

            (mkBind "SUPER + mouse_down" ''hl.dsp.focus({ workspace = "e+1" })'')
            (mkBind "SUPER + mouse_up" ''hl.dsp.focus({ workspace = "e-1" })'')

            (mkExecBindWith "XF86AudioRaiseVolume" "${pkgs.swayosd}/bin/swayosd-client --output-volume +5" {
              repeating = true;
              locked = true;
            })
            (mkExecBindWith "XF86AudioLowerVolume" "${pkgs.swayosd}/bin/swayosd-client --output-volume -5" {
              repeating = true;
              locked = true;
            })
            (mkExecBindWith "XF86MonBrightnessUp" "${pkgs.swayosd}/bin/swayosd-client --brightness +5" {
              repeating = true;
              locked = true;
            })
            (mkExecBindWith "XF86MonBrightnessDown" "${pkgs.swayosd}/bin/swayosd-client --brightness -5" {
              repeating = true;
              locked = true;
            })

            (mkExecBindWith "XF86AudioMute" "${pkgs.swayosd}/bin/swayosd-client --output-volume mute-toggle" {
              locked = true;
            })
            (mkExecBindWith "XF86AudioMicMute" "${pkgs.swayosd}/bin/swayosd-client --input-volume mute-toggle" {
              locked = true;
            })
            (mkExecBindWith "XF86AudioPlay" "${pkgs.swayosd}/bin/swayosd-client --playerctl play-pause" {
              locked = true;
            })
            (mkExecBindWith "XF86AudioNext" "${pkgs.swayosd}/bin/swayosd-client --playerctl next" {
              locked = true;
            })
            (mkExecBindWith "XF86AudioPrev" "${pkgs.swayosd}/bin/swayosd-client --playerctl prev" {
              locked = true;
            })
            (mkExecBindWith "XF86KbdBrightnessUp" "${keyboardBacklight} up" {
              repeating = true;
              locked = true;
            })
            (mkExecBindWith "XF86KbdBrightnessDown" "${keyboardBacklight} down" {
              repeating = true;
              locked = true;
            })
            (mkExecBindWith "switch:on:Lid Switch" clamshell { locked = true; })
            (mkExecBindWith "switch:off:Lid Switch" clamshell { locked = true; })
          ];
        };
      };
    };
}
