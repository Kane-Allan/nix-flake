{ pkgs, vars, ... }:
let
  jdk = pkgs.jdk21;
  jdk17 = pkgs.jdk17;

  androidSdkRoot = "${vars.home}/Android/Sdk";
  androidNdkVersion = "27.1.12297006";
  androidNdkRoot = "${androidSdkRoot}/ndk/${androidNdkVersion}";
  cmdlineToolsZip = pkgs.androidenv.androidPkgs.cmdline-tools-package.archives;
  bumble = pkgs.python313Packages.bumble;

  androidStudio = pkgs.android-studio.override {
    tiling_wm = true;
    forceWayland = true;
  };

  androidStudioProperties = pkgs.writeText "android-studio.properties" ''
    ide.no.platform.update=true
  '';

  androidEnv = ''
    export JAVA_HOME=${jdk.home}
    export ANDROID_HOME=${androidSdkRoot}
    export ANDROID_SDK_ROOT=${androidSdkRoot}
    export ANDROID_NDK_HOME=${androidNdkRoot}
    export ANDROID_NDK_ROOT=${androidNdkRoot}
    export ANDROID_AVD_HOME="''${ANDROID_AVD_HOME:-${vars.home}/.android/avd}"
    export ANDROID_EMULATOR_USE_SYSTEM_LIBS=1
    export QT_QPA_PLATFORM="''${QT_QPA_PLATFORM:-xcb}"
    export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"
  '';

  bootstrapCmdlineTools = ''
    if [ ! -x "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" ]; then
      tmp_dir=$(mktemp -d)

      mkdir -p "$ANDROID_HOME/cmdline-tools"
      unzip -q ${cmdlineToolsZip} -d "$tmp_dir"
      rm -rf "$ANDROID_HOME/cmdline-tools/latest"
      mv "$tmp_dir/cmdline-tools" "$ANDROID_HOME/cmdline-tools/latest"
      rm -rf "$tmp_dir"
    fi
  '';

  androidSdkDoctor = pkgs.writeShellApplication {
    name = "android-sdk-doctor";
    runtimeInputs = [
      jdk
      pkgs.coreutils
      pkgs.unzip
    ];
    text = ''
      ${androidEnv}
      ${bootstrapCmdlineTools}

      sdkmanager="$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager"
      missing=0

      check_path() {
        label="$1"
        path="$2"

        if [ -e "$path" ]; then
          printf 'ok: %s (%s)\n' "$label" "$path"
        else
          printf 'missing: %s (%s)\n' "$label" "$path" >&2
          missing=1
        fi
      }

      mkdir -p "$ANDROID_HOME" "$ANDROID_AVD_HOME"

      if [ -w "$ANDROID_HOME" ]; then
        printf 'ok: SDK root is writable (%s)\n' "$ANDROID_HOME"
      else
        printf 'missing: SDK root is not writable (%s)\n' "$ANDROID_HOME" >&2
        missing=1
      fi

      printf 'JAVA_HOME=%s\n' "$JAVA_HOME"
      printf 'ANDROID_HOME=%s\n' "$ANDROID_HOME"
      printf 'ANDROID_NDK_HOME=%s\n' "$ANDROID_NDK_HOME"

      check_path sdkmanager "$sdkmanager"
      check_path adb "$ANDROID_HOME/platform-tools/adb"
      check_path emulator "$ANDROID_HOME/emulator/emulator"
      check_path 'Android 36 platform' "$ANDROID_HOME/platforms/android-36/android.jar"
      check_path 'Build tools 36.0.0 aapt2' "$ANDROID_HOME/build-tools/36.0.0/aapt2"
      check_path 'NDK 27.1.12297006' "$ANDROID_NDK_HOME/ndk-build"
      check_path 'CMake 3.22.1' "$ANDROID_HOME/cmake/3.22.1/bin/cmake"

      if [ "$missing" -ne 0 ]; then
        printf '\nRun android-sdk-install to install the missing writable SDK components.\n' >&2
        exit 1
      fi
    '';
  };

  androidSdkInstall = pkgs.writeShellApplication {
    name = "android-sdk-install";
    runtimeInputs = [
      androidSdkDoctor
      jdk
      pkgs.coreutils
      pkgs.unzip
    ];
    text = ''
      ${androidEnv}
      ${bootstrapCmdlineTools}

      sdkmanager="$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager"
      packages=(
        "platform-tools"
        "emulator"
        "platforms;android-35"
        "platforms;android-36"
        "build-tools;35.0.0"
        "build-tools;36.0.0"
        "ndk;${androidNdkVersion}"
        "cmake;3.22.1"
        "system-images;android-36;google_apis;x86_64"
      )

      if [ "$#" -gt 0 ]; then
        packages+=("$@")
      fi

      mkdir -p "$ANDROID_HOME" "$ANDROID_AVD_HOME"
      yes | "$sdkmanager" --sdk_root="$ANDROID_HOME" --licenses >/dev/null || true
      "$sdkmanager" --sdk_root="$ANDROID_HOME" --install "''${packages[@]}"
      yes | "$sdkmanager" --sdk_root="$ANDROID_HOME" --licenses >/dev/null || true

      android-sdk-doctor
    '';
  };

  androidAvdEnsure = pkgs.writeShellApplication {
    name = "android-avd-ensure";
    runtimeInputs = [
      androidSdkInstall
      jdk
      pkgs.coreutils
      pkgs.gnugrep
      pkgs.gnused
      pkgs.unzip
    ];
    text = ''
      ${androidEnv}
      ${bootstrapCmdlineTools}

      avd_name="Pixel_API_36"
      avd_package="system-images;android-36;google_apis;x86_64"
      emulator_bin="$ANDROID_HOME/emulator/emulator"
      avdmanager="$ANDROID_HOME/cmdline-tools/latest/bin/avdmanager"

      if [ "$#" -ge 1 ]; then
        avd_name="$1"
      fi

      if [ "$#" -ge 2 ]; then
        avd_package="$2"
      fi

      android-sdk-install "$avd_package" >/dev/null
      mkdir -p "$ANDROID_AVD_HOME"

      if "$emulator_bin" -list-avds | grep -Fxq "$avd_name"; then
        exit 0
      fi

      create_avd() {
        device_args=(--device "pixel_8")
        if ! printf 'no\n' | "$avdmanager" create avd --force --name "$avd_name" --package "$avd_package" "''${device_args[@]}"; then
          rm -rf "$ANDROID_AVD_HOME/$avd_name.avd" "$ANDROID_AVD_HOME/$avd_name.ini"
          printf 'no\n' | "$avdmanager" create avd --force --name "$avd_name" --package "$avd_package"
        fi
      }

      set_config() {
        key="$1"
        value="$2"
        file="$3"

        if grep -q "^$key=" "$file"; then
          sed -i "s|^$key=.*|$key=$value|" "$file"
        else
          printf '%s=%s\n' "$key" "$value" >> "$file"
        fi
      }

      create_avd

      config_file="$ANDROID_AVD_HOME/$avd_name.avd/config.ini"
      if [ -f "$config_file" ]; then
        set_config "hw.keyboard" "yes" "$config_file"
        set_config "showDeviceFrame" "no" "$config_file"
      fi
    '';
  };

  androidEmulator = pkgs.writeShellApplication {
    name = "android-emulator";
    runtimeInputs = [
      androidAvdEnsure
      jdk
      pkgs.coreutils
      pkgs.fzf
      pkgs.gnused
      pkgs.unzip
    ];
    text = ''
      ${androidEnv}

      android-avd-ensure

      emulator_bin="$ANDROID_HOME/emulator/emulator"
      avd_list=$("$emulator_bin" -list-avds | sed '/^$/d')
      if [ -z "$avd_list" ]; then
        printf 'No Android virtual devices are available.\n' >&2
        exit 1
      fi

      if [ "$#" -ge 1 ]; then
        avd_name="$1"
        shift
      else
        avd_name=$(printf '%s\n' "$avd_list" | fzf --prompt='AVD> ')
      fi

      if [ -z "$avd_name" ]; then
        exit 1
      fi

      exec "$emulator_bin" "@$avd_name" -gpu host -no-snapshot-save "$@"
    '';
  };

  androidEmulatorBumble = pkgs.writeShellApplication {
    name = "android-emulator-bumble";
    runtimeInputs = [
      androidAvdEnsure
      jdk
      pkgs.coreutils
      pkgs.fzf
      pkgs.gnused
      pkgs.procps
      pkgs.sudo
      pkgs.unzip
    ];
    text = ''
      ${androidEnv}

      android-avd-ensure

      emulator_bin="$ANDROID_HOME/emulator/emulator"
      adb_bin="$ANDROID_HOME/platform-tools/adb"

      avd_list=$("$emulator_bin" -list-avds | sed '/^$/d')
      if [ -z "$avd_list" ]; then
        printf 'No Android virtual devices are available.\n' >&2
        exit 1
      fi

      if [ "$#" -ge 1 ]; then
        avd_name="$1"
        shift
      else
        avd_name=$(printf '%s\n' "$avd_list" | fzf --prompt='AVD> ')
      fi

      if [ -z "$avd_name" ]; then
        exit 1
      fi

      hci_device="''${ANDROID_BUMBLE_HCI:-hci0}"
      hci_index="''${hci_device#hci}"
      host_transport="''${ANDROID_BUMBLE_HOST_TRANSPORT:-android-netsim}"
      controller_transport="''${ANDROID_BUMBLE_CONTROLLER_TRANSPORT:-hci-socket:$hci_index}"
      bumble_pid=""
      emulator_pid=""

      cleanup() {
        if [ -n "$bumble_pid" ] && kill -0 "$bumble_pid" 2>/dev/null; then
          kill "$bumble_pid" 2>/dev/null || true
          wait "$bumble_pid" 2>/dev/null || true
        fi

        sudo ${pkgs.bluez}/bin/hciconfig "$hci_device" up >/dev/null 2>&1 || true
        sudo ${pkgs.systemd}/bin/systemctl start bluetooth.service >/dev/null 2>&1 || true
      }

      trap cleanup EXIT INT TERM

      sudo -v
      sudo ${pkgs.systemd}/bin/systemctl stop bluetooth.service
      sudo ${pkgs.bluez}/bin/hciconfig "$hci_device" down || true

      "$emulator_bin" "@$avd_name" -gpu host -no-snapshot-save "$@" &
      emulator_pid=$!

      timeout 90 "$adb_bin" wait-for-device >/dev/null 2>&1 || true
      sleep 5

      sudo -E ${bumble}/bin/bumble-hci-bridge "$host_transport" "$controller_transport" &
      bumble_pid=$!

      wait "$emulator_pid"
    '';
  };
in
{
  nixpkgs.config.android_sdk.accept_license = true;

  programs.java = {
    enable = true;
    package = jdk;
  };

  users.users.${vars.user}.extraGroups = [ "kvm" ];

  environment = {
    variables = {
      JAVA_HOME = "${jdk.home}";
      ANDROID_HOME = androidSdkRoot;
      ANDROID_SDK_ROOT = androidSdkRoot;
      ANDROID_NDK_HOME = androidNdkRoot;
      ANDROID_NDK_ROOT = androidNdkRoot;
      ANDROID_AVD_HOME = "${vars.home}/.android/avd";
      ANDROID_EMULATOR_USE_SYSTEM_LIBS = "1";
      STUDIO_PROPERTIES = "${androidStudioProperties}";
      GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${androidSdkRoot}/build-tools/36.0.0/aapt2 -Dorg.gradle.java.installations.paths=${jdk17.home},${jdk.home} -Dorg.gradle.java.installations.auto-download=false";
    };

    systemPackages = [
      androidStudio
      jdk
      jdk17
      bumble
      androidSdkDoctor
      androidSdkInstall
      androidAvdEnsure
      androidEmulator
      androidEmulatorBumble
    ];
  };
}
