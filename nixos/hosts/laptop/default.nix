{ pkgs, ... }:
let
  # fixes an issue where after sleep the gpu doesn't wake properly
  amdPstateResume = pkgs.writeShellScript "amd-pstate-resume" ''
    if [ "$1" != "post" ]; then
      exit 0
    fi

    if [ -w /sys/firmware/acpi/platform_profile ]; then
      printf 'balanced\n' > /sys/firmware/acpi/platform_profile
    fi

    for governor in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
      [ -w "$governor" ] && printf 'powersave\n' > "$governor"
    done

    for preference in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
      [ -w "$preference" ] && printf 'balance_performance\n' > "$preference"
    done
  '';

  runeliteIcon = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/runelite/launcher/master/appimage/runelite.png";
    hash = "sha256-gcts59jEuRVOmECrnSk40OYjTyJwSfAEys+Qck+VzBE=";
  };
  runeliteDesktop = pkgs.runCommand "runelite-desktop-entry" { } ''
    install -Dm644 ${runeliteIcon} $out/share/icons/hicolor/256x256/apps/runelite.png
    install -Dm644 ${runeliteIcon} $out/share/icons/hicolor/256x256/apps/RuneLite.png
    install -Dm644 ${runeliteIcon} $out/share/icons/hicolor/256x256/apps/net.runelite.RuneLite.png
    install -Dm644 ${runeliteIcon} $out/share/icons/hicolor/256x256/apps/net-runelite-client-RuneLite.png

    install -Dm644 /dev/stdin $out/share/applications/net-runelite-client-RuneLite.desktop <<'EOF'
    [Desktop Entry]
    Type=Application
    Name=RuneLite
    Comment=RuneLite client launched through Bolt Launcher
    Exec=bolt-launcher
    Icon=runelite
    StartupWMClass=net-runelite-client-RuneLite
    Categories=Game;
    NoDisplay=true
    EOF
  '';
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 5;
    };

    efi.canTouchEfiVariables = true;
  };

  environment.systemPackages = with pkgs; [
    bolt-launcher
    runeliteDesktop
  ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  environment.etc."systemd/system-sleep/amd-pstate-resume".source = amdPstateResume;
}
