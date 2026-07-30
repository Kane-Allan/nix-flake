{ vars, ... }:
{
  home = {
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      TERMINAL = vars.terminal;
      BROWSER = vars.browser;
    };

    sessionPath = [
      "$PNPM_HOME"
      "$HOME/.dotnet/tools"
      "$HOME/go/bin"
    ];
  };
}
