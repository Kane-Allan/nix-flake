{
  pkgs,
  ...
}:
{
  programs.vscode = {
    enable = true;
    mutableExtensionsDir = false;

    profiles.default = {
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;

      extensions = with pkgs.vscode-marketplace; [

        # microsoft
        ms-vscode-remote.remote-ssh
        ms-vscode.remote-explorer
        ms-vscode-remote.remote-ssh-edit
        ms-azuretools.vscode-docker
        ms-azuretools.vscode-containers
        ms-vscode.hexeditor
        ms-vscode-remote.remote-containers

        ms-azuretools.vscode-azureappservice
        ms-azuretools.vscode-azureresourcegroups

        # vim
        vscodevim.vim
        vspacecode.whichkey

        # languages
        jnoortheen.nix-ide
        golang.go
        mikestead.dotenv
        sumneko.lua
        bmewburn.vscode-intelephense-client

        ms-dotnettools.csharp
        pkgs.vscode-extensions.ms-dotnettools.csdevkit
        ms-dotnettools.vscode-dotnet-runtime
        patcx.vscode-nuget-gallery
        kreativ-software.csharpextensions
        csharpier.csharpier-vscode

        # ts
        yoavbls.pretty-ts-errors
        dbaeumer.vscode-eslint
        christian-kohler.npm-intellisense
        esbenp.prettier-vscode
        bradlc.vscode-tailwindcss
        expo.vscode-expo-tools
        orta.vscode-jest

        #c/pp
        ms-vscode.cpptools
        ms-vscode.cmake-tools

        # utilities
        alexcvzz.vscode-sqlite
        patbenatar.advanced-new-file
        alefragnani.bookmarks
        gruntfuggly.todo-tree
        ms-vscode.hexeditor
        christian-kohler.path-intellisense
        amodio.toggle-excluded-files
        streetsidesoftware.code-spell-checker
        editorconfig.editorconfig
        eamodio.gitlens
        timgthomas.explorer-gitignore
        lokalise.i18n-ally
        rangav.vscode-thunder-client
        redhat.vscode-yaml
        openai.chatgpt

        # UI
        usernamehw.errorlens
        aaron-bond.better-comments
        naumovs.color-highlight
      ];

      userSettings = {
        # general
        "window.titleBarStyle" = "custom";
        "redhat.telemetry.enabled" = false;

        "files.exclude" = {
          ".gitignore" = false;
          "**/.*" = false;
          "**/bin" = false;
          "**/dist" = false;
          "**/node_modules" = false;
          "**/obj" = false;
        };

        # workbench settings
        "workbench.layoutControl.enabled" = false;
        "workbench.sideBar.location" = "right";

        # editor settings
        "editor.inlineSuggest.enabled" = true;
        "editor.suggestOnTriggerCharacters" = true;
        "editor.accessibilitySupport" = "off";

        # visual
        # "editor.fontSize" = 18;
        "editor.lineNumbers" = "relative";
        "editor.minimap.enabled" = false;
        "editor.scrollbar.horizontal" = "hidden";
        "editor.scrollbar.vertical" = "hidden";
        "editor.wordWrap" = "on";
        "editor.bracketPairColorization.independentColorPoolPerBracketType" = true;

        # formatting
        "editor.formatOnSave" = true;
        "editor.formatOnPaste" = true;
        "editor.tabSize" = 2;
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
        "editor.codeActionsOnSave" = {
          "source.fixAll.eslint" = "explicit";
          "source.organizeImports" = "explicit";
        };

        # cspell
        "cSpell.language" = "en-GB";

        # terminal settings
        # "terminal.integrated.fontSize" = 16;

        # vim

        # settings
        "vim.autoindent" = true;
        "vim.useCtrlKeys" = true;
        "vim.easymotion" = true;
        "vim.highlightedyank.enable" = true;
        "vim.hlsearch" = true;
        "vim.incsearch" = true;
        "vim.useSystemClipboard" = true;
        "vim.sneak" = true;
        "vim.ignorecase" = true;
        "vim.smartcase" = true;
        "vim.surround" = true;

        # keybindings
        "vim.normalModeKeyBindingsNonRecursive" = [
          {
            "before" = [
              "<space>"
            ];
            "commands" = [
              "whichkey.show"
            ];
          }
          {
            "before" = [
              "<S-h>"
            ];
            "commands" = [
              "workbench.action.previousEditor"
            ];
          }
          {
            "before" = [
              "<S-l>"
            ];
            "commands" = [
              "workbench.action.nextEditor"
            ];
          }
          {
            "before" = [
              "<S-k>"
            ];
            "commands" = [
              "editor.action.showHover"
            ];
          }
          {
            "before" = [
              ">"
            ];
            "commands" = [
              "tab"
            ];
          }
          {
            "before" = [
              "<"
            ];
            "commands" = [
              "outdent"
            ];
          }
        ];
        "vim.insertModeKeyBindings" = [
          {
            "before" = [
              "j"
              "k"
            ];
            "after" = [
              "<Esc>"
            ];
          }
        ];
        "vim.visualModeKeyBindings" = [
          {
            "before" = [
              " "
              "c"
            ];
            "commands" = [
              "editor.action.commentLine"
            ];
          }
          {
            "before" = [
              ">"
            ];
            "commands" = [
              "tab"
            ];
          }
          {
            "before" = [
              "<"
            ];
            "commands" = [
              "outdent"
            ];
          }
        ];
        "vim.handleKeys" = {
          "<C-k>" = false;
        };

        # whichkey
        "whichkey.sortOrder" = "alphabetically";
        "whichkey.bindings" = [
          {
            "key" = "f";
            "name" = "Find File";
            "type" = "command";
            "command" = "workbench.action.quickOpen";
          }
          {
            "key" = "p";
            "name" = "Command Palette";
            "type" = "command";
            "command" = "workbench.action.showCommands";
          }
          {
            "key" = "c";
            "name" = "Toggle Comment";
            "type" = "command";
            "command" = "editor.action.commentLine";
          }
          {
            "key" = "n";
            "name" = "New File";
            "type" = "command";
            "command" = "extension.advancedNewFile";
          }
          {
            "key" = "q";
            "name" = "Close Editor";
            "type" = "command";
            "command" = "workbench.action.closeActiveEditor";
          }
          {
            "key" = "g";
            "name" = "Git";
            "type" = "conditional";
            "bindings" = [
              {
                "key" = "when:!sideBarVisible";
                "name" = "Default";
                "type" = "command";
                "command" = "workbench.view.scm";
              }
              {
                "key" = "when:sideBarVisible";
                "name" = "Close Explorer";
                "type" = "command";
                "command" = "workbench.action.closeSidebar";
              }
            ];
          }
          {
            "key" = "e";
            "name" = "Explorer";
            "type" = "conditional";
            "bindings" = [
              {
                "key" = "when:!sideBarVisible";
                "name" = "Default";
                "type" = "command";
                "command" = "workbench.view.explorer";
              }
              {
                "key" = "when:sideBarVisible";
                "name" = "Close Explorer";
                "type" = "command";
                "command" = "workbench.action.closeSidebar";
              }
            ];
          }
          {
            "key" = "s";
            "name" = "Search...";
            "type" = "bindings";
            "bindings" = [
              {
                "key" = "f";
                "name" = "Find";
                "type" = "command";
                "command" = "editor.action.startFindReplaceAction";
              }
              {
                "key" = "r";
                "name" = "Replace";
                "type" = "command";
                "command" = "editor.action.startFindReplaceAction";
              }
              {
                "key" = "p";
                "name" = "Find in Project";
                "type" = "conditional";
                "bindings" = [
                  {
                    "key" = "when:!sideBarVisible";
                    "name" = "Default";
                    "type" = "command";
                    "command" = "workbench.view.search";
                  }
                  {
                    "key" = "when:sideBarVisible";
                    "name" = "Close Explorer";
                    "type" = "command";
                    "command" = "workbench.action.closeSidebar";
                  }
                ];
              }
            ];
          }
          {
            "key" = "d";
            "name" = "Debug...";
            "type" = "bindings";
            "bindings" = [
              {
                "key" = "c";
                "name" = "Continue";
                "type" = "command";
                "command" = "workbench.action.debug.continue";
              }
              {
                "key" = "d";
                "name" = "Detatch";
                "type" = "command";
                "command" = "workbench.action.debug.stop";
              }
              {
                "key" = "s";
                "name" = "Start";
                "type" = "command";
                "command" = "workbench.action.debug.start";
              }
              {
                "key" = "i";
                "name" = "Step Into";
                "type" = "command";
                "command" = "workbench.action.debug.stepInto";
              }
              {
                "key" = "o";
                "name" = "Step over";
                "type" = "command";
                "command" = "workbench.action.debug.stepOver";
              }
              {
                "key" = "O";
                "name" = "Step out";
                "type" = "command";
                "command" = "workbench.action.debug.stepOut";
              }
              {
                "key" = "r";
                "name" = "Restart";
                "type" = "command";
                "command" = "workbench.action.debug.restart";
              }
              {
                "key" = "b";
                "name" = "Toggle Breakpoint";
                "type" = "command";
                "command" = "editor.debug.action.toggleBreakpoint";
              }
            ];
          }
          {
            "key" = "x";
            "name" = "Error...";
            "type" = "bindings";
            "bindings" = [
              {
                "key" = "n";
                "name" = "Next Error";
                "type" = "command";
                "command" = "editor.action.marker.next";
              }
              {
                "key" = "p";
                "name" = "Previous Error";
                "type" = "command";
                "command" = "editor.action.marker.prev";
              }
            ];
          }
          {
            "key" = "l";
            "name" = "Lsp...";
            "type" = "bindings";
            "bindings" = [
              {
                "key" = "n";
                "name" = "Next Diagnostic";
                "type" = "command";
                "command" = "editor.action.marker.next";
              }
              {
                "key" = "p";
                "name" = "Previous Diagnostic";
                "type" = "command";
                "command" = "editor.action.marker.prev";
              }
            ];
          }
          {
            "key" = "b";
            "name" = "Bookmarks...";
            "type" = "bindings";
            "bindings" = [
              {
                "key" = "n";
                "name" = "Next Bookmark";
                "type" = "command";
                "command" = "bookmarks.jumpToNext";
              }
              {
                "key" = "p";
                "name" = "Previous Bookmark";
                "type" = "command";
                "command" = "bookmarks.jumpToPrevious";
              }
              {
                "key" = "t";
                "name" = "Toggle Bookmark";
                "type" = "command";
                "command" = "bookmarks.toggle";
              }
              {
                "key" = "c";
                "name" = "Clear Bookmarks";
                "type" = "command";
                "command" = "bookmarks.clear";
              }
              {
                "key" = "C";
                "name" = "Clear all bookmarks";
                "type" = "command";
                "command" = "bookmarks.clearFromAllFiles";
              }
              {
                "key" = "l";
                "name" = "List Bookmarks";
                "type" = "command";
                "command" = "bookmarks.list";
              }
              {
                "key" = "L";
                "name" = "List all bookmarks";
                "type" = "command";
                "command" = "bookmarks.listFromAllFiles";
              }
            ];
          }
          {
            "key" = "n";
            "name" = "No highlight";
            "type" = "command";
            "command" = "vscode-neovim.send";
            "args" = ":noh<CR>";
          }
          {
            "key" = "i";
            "name" = "Suggestions";
            "type" = "command";
            "command" = "editor.action.triggerSuggest";
          }
          {
            "key" = "r";
            "name" = "Refactor...";
            "type" = "bindings";
            "bindings" = [
              {
                "key" = "n";
                "name" = "Rename Symbol";
                "type" = "command";
                "command" = "editor.action.rename";
              }
            ];
          }
        ];

        # advanced new file
        "advancedNewFile.exclude" = {
          "node_modules" = true;
          "node_modules_electron" = true;
          "dev" = true;
          "dist" = true;
        };
        "advancedNewFile.showInformationMessages" = true;
        "advancedNewFile.convenienceOptions" = [
          "last"
          "current"
          "root"
        ];

        # languages
        # php
        "[php]" = {
          "editor.defaultFormatter" = "bmewburn.vscode-intelephense-client";
        };

        # javascript
        "javascript.updateImportsOnFileMove.enabled" = "always";

        ## default prettier
        "prettier.arrowParens" = "avoid";
        "prettier.printWidth" = 100;
        "prettier.singleQuote" = false;
        "prettier.trailingComma" = "none";

        # csharp
        "[csharp]" = {
          "editor.defaultFormatter" = "csharpier.csharpier-vscode";
          "editor.tabSize" = 4;
        };
        "csharpextensions.useThisForCtorAssignments" = false;
        "csharpextensions.privateMemberPrefix" = "_";
        "csharpextensions.useFileScopedNamespace" = true;

        # lua
        "[lua]" = {
          "editor.defaultFormatter" = "sumneko.lua";
        };

        # nix
        "[nix]" = {
          "editor.defaultFormatter" = "jnoortheen.nix-ide";
        };
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nil";
        "nix.formatterPath" = "nixfmt";
        "nix.serverSettings" = {
          "nil" = {
            "formatting" = {
              "command" = [ "nixfmt" ];
            };
          };
        };

        # c/pp
        "[c]" = {
          "editor.defaultFormatter" = "ms-vscode.cpptools";
        };

        "[cpp]" = {
          "editor.defaultFormatter" = "ms-vscode.cpptools";
        };

        "idf.hasWalkthroughBeenShown" = "true";
      };

      keybindings = [
        {
          key = "space";
          command = "whichkey.show";
          when = "activeEditorGroupEmpty && focusedView == '' && !whichkeyActive && !inputFocus";
        }
        {
          key = "space";
          command = "whichkey.show";
          when = "sideBarFocus && !inputFocus && !whichkeyActive";
        }
        {
          key = "e";
          command = "whichkey.triggerKey";
          args = {
            key = "e";
            when = "!sideBarVisible";
          };
          when = "whichkeyVisible && !sideBarVisible";
        }
        {
          key = "e";
          command = "whichkey.triggerKey";
          args = {
            key = "e";
            when = "sideBarVisible";
          };
          when = "whichkeyVisible && sideBarVisible";
        }
        {
          key = "g";
          command = "whichkey.triggerKey";
          args = {
            key = "g";
            when = "!sideBarVisible";
          };
          when = "whichkeyVisible && !sideBarVisible";
        }
        {
          key = "g";
          command = "whichkey.triggerKey";
          args = {
            key = "g";
            when = "sideBarVisible";
          };
          when = "whichkeyVisible && sideBarVisible";
        }
        {
          key = "p";
          command = "whichkey.triggerKey";
          args = {
            key = "p";
            when = "!sideBarVisible";
          };
          when = "whichkeyVisible && !sideBarVisible";
        }
        {
          key = "p";
          command = "whichkey.triggerKey";
          args = {
            key = "p";
            when = "sideBarVisible";
          };
          when = "whichkeyVisible && sideBarVisible";
        }
        {
          key = "ctrl+h";
          command = "workbench.action.navigateLeft";
          when = "!inQuickOpen && !suggestWidgetVisible && !parameterHintsVisible && !isInDiffEditor";
        }
        {
          key = "ctrl+j";
          command = "workbench.action.navigateDown";
          when = "!inQuickOpen && !suggestWidgetVisible && !parameterHintsVisible";
        }
        {
          key = "ctrl+k";
          command = "workbench.action.navigateUp";
          when = "!inQuickOpen && !suggestWidgetVisible && !parameterHintsVisible";
        }
        {
          key = "ctrl+l";
          command = "workbench.action.navigateRight";
          when = "!inQuickOpen && !suggestWidgetVisible && !parameterHintsVisible && !isInDiffEditor";
        }
        {
          key = "ctrl+h";
          command = "workbench.action.compareEditor.focusSecondarySide";
          when = "isInDiffEditor && !isInDiffLeftEditor";
        }
        {
          key = "ctrl+h";
          command = "workbench.action.navigateLeft";
          when = "isInDiffEditor && isInDiffLeftEditor";
        }
        {
          key = "ctrl+l";
          command = "workbench.action.compareEditor.focusPrimarySide";
          when = "isInDiffEditor && isInDiffLeftEditor";
        }
        {
          key = "ctrl+l";
          command = "workbench.action.navigateRight";
          when = "isInDiffEditor && !isInDiffLeftEditor";
        }
        {
          key = "ctrl+h";
          command = "list.collapse";
          when = "listFocus && !inputFocus";
        }
        {
          key = "ctrl+l";
          command = "list.expand";
          when = "listFocus && !inputFocus";
        }
        {
          key = "ctrl+j";
          command = "list.focusDown";
          when = "listFocus && !inputFocus";
        }
        {
          key = "ctrl+k";
          command = "list.focusUp";
          when = "listFocus && !inputFocus";
        }
        {
          key = "ctrl+j";
          command = "selectNextSuggestion";
          when = "editorTextFocus && suggestWidgetMultipleSuggestions && suggestWidgetVisible";
        }
        {
          key = "ctrl+k";
          command = "selectPrevSuggestion";
          when = "editorTextFocus && suggestWidgetMultipleSuggestions && suggestWidgetVisible";
        }
        {
          key = "ctrl+k";
          command = "workbench.action.quickOpenPreviousEditor";
          when = "inQuickOpen";
        }
        {
          key = "ctrl+j";
          command = "workbench.action.quickOpenNavigateNext";
          when = "inQuickOpen";
        }
        {
          key = "r";
          command = "renameFile";
          when = "explorerViewletVisible && filesExplorerFocus && !explorerResourceIsRoot && !explorerResourceReadonly && !inputFocus";
        }
        {
          key = "ctrl+v";
          command = "workbench.action.splitEditorRight";
          when = "explorerViewletVisible && filesExplorerFocus && !explorerResourceIsRoot && !explorerResourceReadonly && !inputFocus";
        }
        {
          key = "enter";
          command = "-renameFile";
          when = "explorerViewletVisible && filesExplorerFocus && !explorerResourceIsRoot && !explorerResourceReadonly && !inputFocus";
        }
        {
          command = "runCommands";
          key = "shift+h";
          args = {
            commands = [
              "toggleexcludedfiles.toggle"
              "explorer-gitignore.toggle"
            ];
          };
          when = "explorerViewletVisible && filesExplorerFocus && !inputFocus";
        }
        {
          key = "enter";
          command = "list.select";
          when = "explorerViewletVisible && filesExplorerFocus";
        }
        {
          key = "a";
          command = "explorer.newFile";
          when = "filesExplorerFocus && !inputFocus";
        }
        {
          key = "shift+a";
          command = "explorer.newFolder";
          when = "filesExplorerFocus && !inputFocus";
        }
        {
          key = "d";
          command = "deleteFile";
          when = "filesExplorerFocus && !inputFocus";
        }
        {
          key = "ctrl+t";
          command = "workbench.action.terminal.toggleTerminal";
          when = "vim.mode !== 'Insert'";
        }
        {
          key = "ctrl+shift+j";
          command = "editor.action.moveLinesDownAction";
          when = "vim.mode !== 'Insert' && editorTextFocus";
        }
        {
          key = "ctrl+shift+k";
          command = "editor.action.moveLinesUpAction";
          when = "vim.mode !== 'Insert' && editorTextFocus";
        }
      ];
    };
  };
}
