{ vars, ... }:
let
  androidSdkRoot = "${vars.home}/Android/Sdk";
  androidNdkRoot = "${androidSdkRoot}/ndk/27.1.12297006";
in
{
  home = {
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      TERMINAL = vars.terminal;
      BROWSER = vars.browser;
      PNPM_HOME = "${vars.home}/.local/share/pnpm";
      ANDROID_HOME = androidSdkRoot;
      ANDROID_SDK_ROOT = androidSdkRoot;
      ANDROID_NDK_HOME = androidNdkRoot;
      ANDROID_NDK_ROOT = androidNdkRoot;
      ANDROID_AVD_HOME = "${vars.home}/.android/avd";
      ANDROID_EMULATOR_USE_SYSTEM_LIBS = "1";
    };

    sessionPath = [
      "$PNPM_HOME"
      "$ANDROID_HOME/cmdline-tools/latest/bin"
      "$ANDROID_HOME/platform-tools"
      "$ANDROID_HOME/emulator"
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
