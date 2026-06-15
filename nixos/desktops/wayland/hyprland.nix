{
  inputs,
  pkgs,
  vars,
  lib,
  ...
}:
let
  noctalia = lib.getExe inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
  noctaliaMsg = "${noctalia} msg";
in
{
  security.pam.services.hyprlock = { };

  environment.sessionVariables = {
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
  };

  xdg.portal = {
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    config.common.default = lib.mkForce [
      "hyprland"
      "gtk"
    ];
  };

  home-manager.users.${vars.user} =
    let
      monitor = "eDP-1";
      monitorMode = if vars.hyprland.resolution == "" then "preferred" else vars.hyprland.resolution;
      monitor_config = toLua {
        output = monitor;
        mode = monitorMode;
        position = "0x0";
        scale = vars.hyprland.scale;
      };
      monitor_disable = toLua {
        output = monitor;
        disabled = true;
      };
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
        exec ${pkgs.ghostty}/bin/ghostty --title=tmux --class=ghostty -e ${pkgs.zsh}/bin/zsh -l -c '${pkgs.tmux}/bin/tmux attach || ${pkgs.tmux}/bin/tmux'
      '';

      yaziTerminal = pkgs.writeShellScript "ghostty-yazi" ''
        exec ${pkgs.ghostty}/bin/ghostty --title=yazi --class=yazi -e ${pkgs.yazi}/bin/yazi
      '';

      clamshell = pkgs.writeShellScript "hypr-clamshell" ''
        action="''${1:-}"

        if [[ "$action" == "open" ]]; then
          ${pkgs.hyprland}/bin/hyprctl eval ${lib.escapeShellArg "hl.monitor(${monitor_config})"}
          sleep 0.5
          ${pkgs.hyprland}/bin/hyprctl dispatch dpms on ${monitor}
        elif [[ "$action" == "close" ]]; then
          if [[ $(${pkgs.hyprland}/bin/hyprctl monitors 2>/dev/null | ${pkgs.ripgrep}/bin/rg "^Monitor " | ${pkgs.ripgrep}/bin/rg -v "^Monitor ${monitor} ") ]]; then
            ${pkgs.hyprland}/bin/hyprctl eval ${lib.escapeShellArg "hl.monitor(${monitor_disable})"}
          else
            ${lockCommand}
          fi
        fi
      '';
    in
    {
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
              output = "desc:AOC U34E2M 1R2R6HA001557";
              mode = "3440x1440@99.98";
              position = "auto";
              scale = 1;
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
                  hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE")
                  hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE")
                  -- hl.exec_cmd("${pkgs.systemd}/bin/systemctl --user restart noctalia.service")
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

            misc = {
              force_default_wallpaper = 0;
              disable_hyprland_logo = true;
              mouse_move_enables_dpms = true;
              key_press_enables_dpms = true;
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
          ];

          layer_rule = [
            {
              name = "noctalia";
              match.namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd)$";
              ignore_alpha = 0.5;
              blur = true;
              blur_popups = true;
            }
          ];

          bind = [
            (mkExecBind "SUPER + Return" tmuxTerminal)
            (mkExecBind "SUPER + SHIFT + Return" "${pkgs.brave}/bin/brave")
            (mkExecBind "SUPER + Space" "${noctaliaMsg} panel-toggle launcher")
            (mkExecBind "SUPER + C" "${noctaliaMsg} panel-toggle control-center")
            (mkExecBind "SUPER + comma" "${noctaliaMsg} settings-toggle")
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

            (mkExecBindWith "XF86AudioRaiseVolume" "${noctaliaMsg} volume-up 5" {
              repeating = true;
              locked = true;
            })
            (mkExecBindWith "XF86AudioLowerVolume" "${noctaliaMsg} volume-down 5" {
              repeating = true;
              locked = true;
            })
            (mkExecBindWith "XF86MonBrightnessUp" "${noctaliaMsg} brightness-up 5" {
              repeating = true;
              locked = true;
            })
            (mkExecBindWith "XF86MonBrightnessDown" "${noctaliaMsg} brightness-down 5" {
              repeating = true;
              locked = true;
            })

            (mkExecBindWith "XF86AudioMute" "${noctaliaMsg} volume-mute" {
              locked = true;
            })
            (mkExecBindWith "XF86AudioMicMute" "${noctaliaMsg} mic-mute" {
              locked = true;
            })
            (mkExecBindWith "XF86AudioPlay" "${noctaliaMsg} media toggle" {
              locked = true;
            })
            (mkExecBindWith "XF86AudioNext" "${noctaliaMsg} media next" {
              locked = true;
            })
            (mkExecBindWith "XF86AudioPrev" "${noctaliaMsg} media previous" {
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
            (mkExecBindWith "switch:on:Lid Switch" "${clamshell} close" { locked = true; })
            (mkExecBindWith "switch:off:Lid Switch" "${clamshell} open" { locked = true; })
          ];
        };
      };
    };
}
