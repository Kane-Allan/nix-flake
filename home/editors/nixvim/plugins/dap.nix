{ lib, pkgs, ... }:
let
  jsDebug = lib.getExe pkgs.vscode-js-debug;
  codelldb = "${pkgs.vscode-extensions.vadimcn.vscode-lldb.adapter}/bin/codelldb";
in
{
  programs.nixvim.plugins = {
    dap = {
      enable = true;
      signs = {
        dapBreakpoint = {
          text = " ";
          texthl = "DiagnosticInfo";
        };
        dapBreakpointCondition = {
          text = " ";
          texthl = "DiagnosticInfo";
        };
        dapBreakpointRejected = {
          text = " ";
          texthl = "DiagnosticError";
        };
        dapLogPoint = {
          text = ".>";
          texthl = "DiagnosticInfo";
        };
        dapStopped = {
          text = " ";
          texthl = "DiagnosticWarn";
          linehl = "DapStoppedLine";
        };
      };

      adapters = {
        pwa-node.__raw = ''
          {
            type = "server",
            host = "127.0.0.1",
            port = "''${port}",
            executable = {
              command = "${jsDebug}",
              args = { "''${port}" },
            },
          }
        '';
        pwa-chrome.__raw = ''
          {
            type = "server",
            host = "127.0.0.1",
            port = "''${port}",
            executable = {
              command = "${jsDebug}",
              args = { "''${port}" },
            },
          }
        '';
        pwa-msedge.__raw = ''
          {
            type = "server",
            host = "127.0.0.1",
            port = "''${port}",
            executable = {
              command = "${jsDebug}",
              args = { "''${port}" },
            },
          }
        '';
        node.__raw = ''
          function(callback, config)
            config.type = "pwa-node"
            callback(require("dap").adapters["pwa-node"])
          end
        '';
        chrome.__raw = ''
          function(callback, config)
            config.type = "pwa-chrome"
            callback(require("dap").adapters["pwa-chrome"])
          end
        '';
        msedge.__raw = ''
          function(callback, config)
            config.type = "pwa-msedge"
            callback(require("dap").adapters["pwa-msedge"])
          end
        '';
        executables.netcoredbg = {
          command = lib.getExe pkgs.netcoredbg;
          args = [ "--interpreter=vscode" ];
          options.detached = false;
        };
        codelldb.__raw = ''
          {
            type = "server",
            host = "127.0.0.1",
            port = "''${port}",
            executable = {
              command = "${codelldb}",
              args = { "--port", "''${port}" },
            },
          }
        '';
      };

      configurations = {
        javascript = [
          {
            type = "pwa-node";
            request = "launch";
            name = "Launch current file";
            program = "\${file}";
            cwd = "\${workspaceFolder}";
            sourceMaps = true;
            skipFiles = [
              "<node_internals>/**"
              "**/node_modules/**"
            ];
          }
          {
            type = "pwa-node";
            request = "attach";
            name = "Attach to process";
            processId.__raw = "require('dap.utils').pick_process";
            cwd = "\${workspaceFolder}";
            sourceMaps = true;
          }
        ];
        typescript = [
          {
            type = "pwa-node";
            request = "launch";
            name = "Launch current file with tsx";
            runtimeExecutable = "tsx";
            runtimeArgs = [ "\${file}" ];
            cwd = "\${workspaceFolder}";
            sourceMaps = true;
            skipFiles = [
              "<node_internals>/**"
              "**/node_modules/**"
            ];
          }
          {
            type = "pwa-node";
            request = "attach";
            name = "Attach to process";
            processId.__raw = "require('dap.utils').pick_process";
            cwd = "\${workspaceFolder}";
            sourceMaps = true;
          }
        ];
        javascriptreact = [
          {
            type = "pwa-node";
            request = "launch";
            name = "Launch current file";
            program = "\${file}";
            cwd = "\${workspaceFolder}";
            sourceMaps = true;
            skipFiles = [
              "<node_internals>/**"
              "**/node_modules/**"
            ];
          }
          {
            type = "pwa-node";
            request = "attach";
            name = "Attach to process";
            processId.__raw = "require('dap.utils').pick_process";
            cwd = "\${workspaceFolder}";
            sourceMaps = true;
          }
        ];
        typescriptreact = [
          {
            type = "pwa-node";
            request = "launch";
            name = "Launch current file with tsx";
            runtimeExecutable = "tsx";
            runtimeArgs = [ "\${file}" ];
            cwd = "\${workspaceFolder}";
            sourceMaps = true;
            skipFiles = [
              "<node_internals>/**"
              "**/node_modules/**"
            ];
          }
          {
            type = "pwa-node";
            request = "attach";
            name = "Attach to process";
            processId.__raw = "require('dap.utils').pick_process";
            cwd = "\${workspaceFolder}";
            sourceMaps = true;
          }
        ];
        cs = [
          {
            type = "netcoredbg";
            request = "launch";
            name = "Launch .NET assembly";
            program.__raw = ''
              function()
                return vim.fn.input("Path to DLL: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
              end
            '';
            cwd = "\${workspaceFolder}";
          }
          {
            type = "netcoredbg";
            request = "attach";
            name = "Attach to .NET process";
            processId.__raw = "require('dap.utils').pick_process";
          }
        ];
        cpp = [
          {
            type = "codelldb";
            request = "launch";
            name = "Launch executable";
            program.__raw = ''
              function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
              end
            '';
            cwd = "\${workspaceFolder}";
            stopOnEntry = false;
          }
          {
            type = "codelldb";
            request = "attach";
            name = "Attach to process";
            pid.__raw = "require('dap.utils').pick_process";
            cwd = "\${workspaceFolder}";
          }
        ];
        c = [
          {
            type = "codelldb";
            request = "launch";
            name = "Launch executable";
            program.__raw = ''
              function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
              end
            '';
            cwd = "\${workspaceFolder}";
            stopOnEntry = false;
          }
          {
            type = "codelldb";
            request = "attach";
            name = "Attach to process";
            pid.__raw = "require('dap.utils').pick_process";
            cwd = "\${workspaceFolder}";
          }
        ];
      };
    };

    dap-ui.enable = true;
    dap-virtual-text.enable = true;
  };

  programs.nixvim.extraConfigLua = ''
    do
      local dap = require("dap")
      local dapui = require("dapui")

      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end

      local json_decode = vim.json.decode
      require("dap.ext.vscode").json_decode = function(str)
        return json_decode(vim.json.encode(vim.fn.json_decode(str)))
      end

      for _, language in ipairs({ "javascript", "javascriptreact", "typescript", "typescriptreact" }) do
        require("dap.ext.vscode").type_to_filetypes["node"] =
          require("dap.ext.vscode").type_to_filetypes["node"] or {}
        if not vim.tbl_contains(require("dap.ext.vscode").type_to_filetypes["node"], language) then
          table.insert(require("dap.ext.vscode").type_to_filetypes["node"], language)
        end
      end
    end
  '';
}
