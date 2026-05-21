{ pkgs, vars, ... }:
let
  jdk = pkgs.jdk21;
  androidSdk = pkgs.androidenv.composeAndroidPackages {
    platformVersions = [
      "36"
      "37"
    ];
    buildToolsVersions = [
      "36.0.0"
      "37.0.0"
    ];
    includeEmulator = true;
    includeSystemImages = true;
    systemImageTypes = [
      "google_apis"
      "google_apis_playstore"
    ];
    abiVersions = [ "x86_64" ];
  };
  androidHome = "${androidSdk.androidsdk}/libexec/android-sdk";
  androidStudio = (pkgs.android-studio.override { tiling_wm = true; }).withSdk androidSdk.androidsdk;
  androidStudioProperties = pkgs.writeText "android-studio.properties" ''
    ide.no.platform.update=true
  '';
  bumble = pkgs.python313Packages.bumble;

  androidEnv = ''
    export JAVA_HOME=${jdk.home}
    export ANDROID_HOME=${androidHome}
    export ANDROID_SDK_ROOT=${androidHome}
    export ANDROID_AVD_HOME="''${ANDROID_AVD_HOME:-$HOME/.android/avd}"
    export ANDROID_EMULATOR_USE_SYSTEM_LIBS=1
    export QT_QPA_PLATFORM="''${QT_QPA_PLATFORM:-xcb}"
  '';

  androidAvdEnsure = pkgs.writeShellApplication {
    name = "android-avd-ensure";
    runtimeInputs = [
      androidSdk.androidsdk
      pkgs.coreutils
      pkgs.gnugrep
      pkgs.gnused
    ];
    text = ''
      ${androidEnv}

      avd_name="Digidown_API_36"
      avd_package="system-images;android-36;google_apis;x86_64"

      if [ "$#" -ge 1 ]; then
        avd_name="$1"
      fi

      if [ "$#" -ge 2 ]; then
        avd_package="$2"
      fi

      mkdir -p "$ANDROID_AVD_HOME"

      if emulator -list-avds | grep -Fxq "$avd_name"; then
        exit 0
      fi

      create_avd() {
        device_args=(--device "pixel_8")
        if ! printf 'no\n' | avdmanager create avd --force --name "$avd_name" --package "$avd_package" "''${device_args[@]}"; then
          rm -rf "$ANDROID_AVD_HOME/$avd_name.avd" "$ANDROID_AVD_HOME/$avd_name.ini"
          printf 'no\n' | avdmanager create avd --force --name "$avd_name" --package "$avd_package"
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

  androidEmulatorSelect = pkgs.writeShellApplication {
    name = "android-emulator-select";
    runtimeInputs = [
      androidSdk.androidsdk
      androidAvdEnsure
      pkgs.coreutils
      pkgs.fzf
      pkgs.gnused
    ];
    text = ''
      ${androidEnv}

      android-avd-ensure

      avd_list=$(emulator -list-avds | sed '/^$/d')
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

      exec emulator "@$avd_name" -gpu host -no-snapshot-save "$@"
    '';
  };

  androidEmulatorBumble = pkgs.writeShellApplication {
    name = "android-emulator-bumble";
    runtimeInputs = [
      androidSdk.androidsdk
      androidAvdEnsure
      pkgs.coreutils
      pkgs.fzf
      pkgs.gnused
      pkgs.procps
      pkgs.sudo
    ];
    text = ''
      ${androidEnv}

      android-avd-ensure

      avd_list=$(emulator -list-avds | sed '/^$/d')
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

      emulator "@$avd_name" -gpu host -no-snapshot-save "$@" &
      emulator_pid=$!

      timeout 90 adb wait-for-device >/dev/null 2>&1 || true
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
      ANDROID_HOME = androidHome;
      ANDROID_SDK_ROOT = androidHome;
      ANDROID_EMULATOR_USE_SYSTEM_LIBS = "1";
      STUDIO_PROPERTIES = "${androidStudioProperties}";
      GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${androidHome}/build-tools/36.0.0/aapt2";
    };

    systemPackages = [
      androidStudio
      androidSdk.androidsdk
      jdk
      bumble
      androidAvdEnsure
      androidEmulatorSelect
      androidEmulatorBumble
    ];
  };
}
