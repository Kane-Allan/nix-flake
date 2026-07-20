{ vars, ... }:
{
  home = {
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      TERMINAL = vars.terminal;
      BROWSER = vars.browser;
      PNPM_HOME = "${vars.home}/.local/share/pnpm";
    };

    sessionPath = [
      "$PNPM_HOME"
      "$HOME/.dotnet/tools"
      "$HOME/go/bin"
    ];

    file = {
      ".npmrc".text = ''
        global-bin-dir=${vars.home}/.local/share/pnpm
        global-dir=${vars.home}/.local/share/pnpm/global
        store-dir=${vars.home}/.local/share/pnpm/store
      '';

      ".local/share/pnpm/.keep".text = "";
      ".local/share/pnpm/global/.keep".text = "";
      ".local/share/pnpm/store/.keep".text = "";
    };
  };
}
