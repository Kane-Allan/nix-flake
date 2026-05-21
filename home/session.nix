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
  };
}
