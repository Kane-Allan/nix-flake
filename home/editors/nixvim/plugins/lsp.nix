{ pkgs, vars, ... }:
let
  typeScriptInlayHints = {
    enumMemberValues.enabled = true;
    functionLikeReturnTypes.enabled = true;
    parameterNames.enabled = "literals";
    parameterTypes.enabled = true;
    propertyDeclarationTypes.enabled = true;
    variableTypes = {
      enabled = false;
      suppressWhenTypeMatchesName = true;
    };
  };

  typeScriptSettings = {
    updateImportsOnFileMove.enabled = "always";
    suggest.completeFunctionCalls = true;
    inlayHints = typeScriptInlayHints;
  };
in
{
  programs.nixvim.plugins.lsp = {
    enable = true;
    inlayHints = true;
    servers = {
      vtsls = {
        enable = true;
        package = pkgs.vtsls;
        settings = {
          complete_function_calls = true;
          javascript = typeScriptSettings;
          typescript = typeScriptSettings;
          vtsls = {
            autoUseWorkspaceTsdk = true;
            enableMoveToFileCodeAction = true;
            experimental = {
              maxInlayHintLength = 30;
              completion.enableServerSideFuzzyMatch = true;
            };
          };
        };
      };
      eslint = {
        enable = true;
        settings = {
          options.flags = [ "unstable_native_nodejs_ts_config" ];
          workingDirectories.mode = "auto";
        };
      };
      tailwindcss = {
        enable = true;
        # nvim-lspconfig falls back to .git for Tailwind v4, which starts the
        # server in every repository. Require an actual Tailwind indicator.
        extraOptions.root_dir.__raw = ''
          function(bufnr, on_dir)
            local util = require("lspconfig.util")
            local fname = vim.api.nvim_buf_get_name(bufnr)
            local markers = {
              "tailwind.config.js",
              "tailwind.config.cjs",
              "tailwind.config.mjs",
              "tailwind.config.ts",
              "postcss.config.js",
              "postcss.config.cjs",
              "postcss.config.mjs",
              "postcss.config.ts",
            }
            markers = util.insert_package_json(markers, "tailwindcss", fname)
            local match = vim.fs.find(markers, { path = fname, upward = true })[1]
            if match then
              on_dir(vim.fs.dirname(match))
              return
            end

            -- Tailwind v4 can be configured only through CSS and an indirect
            -- workspace package. A lockfile dependency is still a reliable
            -- signal without falling back to every Git repository.
            local lockfile = vim.fs.find({
              "package-lock.json",
              "pnpm-lock.yaml",
              "yarn.lock",
              "bun.lock",
              "bun.lockb",
            }, { path = fname, upward = true })[1]
            if lockfile then
              local file = io.open(lockfile, "r")
              local contents = file and file:read("*a") or ""
              if file then
                file:close()
              end
              if contents:find("tailwindcss", 1, true) then
                on_dir(vim.fs.dirname(lockfile))
              end
            end
          end
        '';
      };
      html.enable = true;
      cssls.enable = true;
      jsonls = {
        enable = true;
        package = pkgs.vscode-json-languageserver;
        cmd = [
          "${pkgs.vscode-json-languageserver}/bin/vscode-json-languageserver"
          "--stdio"
        ];
        settings = {
          format.enable = true;
          validate.enable = true;
        };
      };
      marksman.enable = true;
      bashls.enable = true;
      omnisharp = {
        enable = true;
        package = pkgs.omnisharp-roslyn;
        settings = {
          FormattingOptions.EnableEditorConfigSupport = true;
          RoslynExtensionsOptions = {
            EnableAnalyzersSupport = true;
            EnableImportCompletion = true;
          };
        };
      };
      fsautocomplete = {
        enable = true;
        package = pkgs.fsautocomplete;
      };
      cmake.enable = true;
      intelephense = {
        enable = true;
        package = pkgs.intelephense;
      };
      phpactor = {
        enable = true;
        package = pkgs.phpactor;
      };
      nixd = {
        enable = true;
        settings = {
          nixpkgs.expr = ''
            (builtins.getFlake "${vars.flake}").inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}
          '';

          formatting.command = [ "nixfmt" ];

          options = {
            nixos.expr = ''
              (builtins.getFlake "${vars.flake}").nixosConfigurations.${vars.host}.options
            '';
            home-manager.expr = ''
              (builtins.getFlake "${vars.flake}").nixosConfigurations.${vars.host}.options.home-manager.users.type.getSubOptions []
            '';
          };
        };
      };

      clangd = {
        enable = true;
        cmd =
          let
            queryDrivers = [
              "**/bin/*-gcc"
              "**/bin/*-g++"
              "**/bin/gcc"
              "**/bin/g++"
              "**/bin/cc"
              "**/bin/c++"
              "**/bin/clang"
              "**/bin/clang++"
            ];
          in
          [
            "clangd"
            "--background-index"
            "--clang-tidy"
            "--completion-style=detailed"
            "--query-driver=${builtins.concatStringsSep "," queryDrivers}"
          ];
      };

      lua_ls = {
        enable = true;
        settings = {
          diagnostics.globals = [ "vim" ];
          workspace.checkThirdParty = false;
          telemetry.enable = false;
        };
      };
    };
  };

  programs.nixvim.extraConfigLua = ''
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(event)
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if not client or client.name ~= "vtsls" then
          return
        end

        client.commands["_typescript.moveToFileRefactoring"] = function(command)
          local action, uri, range = unpack(command.arguments)
          local function move(destination)
            client:request("workspace/executeCommand", {
              command = command.command,
              arguments = { action, uri, range, destination },
            })
          end

          local filename = vim.uri_to_fname(uri)
          client:request("workspace/executeCommand", {
            command = "typescript.tsserverRequest",
            arguments = {
              "getMoveToRefactoringFileSuggestions",
              {
                file = filename,
                startLine = range.start.line + 1,
                startOffset = range.start.character + 1,
                endLine = range["end"].line + 1,
                endOffset = range["end"].character + 1,
              },
            },
          }, function(_, result)
            local files = result and result.body and result.body.files or {}
            table.insert(files, 1, "Enter new path...")
            vim.ui.select(files, {
              prompt = "Select move destination:",
              format_item = function(file)
                return vim.fn.fnamemodify(file, ":~:.")
              end,
            }, function(destination)
              if not destination then
                return
              end
              if destination == "Enter new path..." then
                vim.ui.input({
                  prompt = "Enter move destination:",
                  default = vim.fn.fnamemodify(filename, ":h") .. "/",
                  completion = "file",
                }, function(input)
                  if input then
                    move(input)
                  end
                end)
              else
                move(destination)
              end
            end)
          end)
        end
      end,
    })
  '';
}
