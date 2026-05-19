{ vars, ... }:
{
  home = {
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      TERMINAL = vars.terminal;
      BROWSER = vars.browser;
      ANDROID_HOME = "${vars.home}/Android/Sdk";
      ANDROID_SDK_ROOT = "${vars.home}/Android/Sdk";
      PNPM_HOME = "${vars.home}/.local/share/pnpm";
    };

    sessionPath = [
      "$ANDROID_HOME/platform-tools"
      "$ANDROID_HOME/emulator"
      "$ANDROID_HOME/cmdline-tools/latest/bin"
      "$PNPM_HOME"
      "$HOME/.dotnet/tools"
      "$HOME/go/bin"
    ];
  };
}
