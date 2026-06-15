{ pkgs, vars, ... }:
let
  unbind-ftdi-sio = pkgs.writeShellScript "unbind-ftdi-sio" ''
    #!/bin/sh
    set -eu

    if [ $# -ne 1 ]; then
      exit 0
    fi

    if [ -w /sys/bus/usb/drivers/ftdi_sio/unbind ]; then
      printf '%s' "$1" > /sys/bus/usb/drivers/ftdi_sio/unbind
    fi
  '';
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader = {
    grub = {
      enable = true;
      configurationLimit = 5;
      efiSupport = true;
      device = "nodev";
      useOSProber = true;
    };

    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi";
    };
  };

  fileSystems."/mnt/shared" = {
    device = "/dev/disk/by-label/Shared";
    fsType = "ntfs3";
    options = [
      "rw"
      "uid=1000"
      "gid=100"
      "umask=022"
      "nofail"
      "windows_names"
    ];
  };

  environment.systemPackages = with pkgs; [
    os-prober
    subversion
    teamviewer
    picoscope
    dbeaver-bin
    cloudflared
  ];

  nixpkgs.config.segger-jlink.acceptLicense = true;

  services.udev.packages = [ pkgs.picoscope.rules ];

  users.groups.pico = { };
  users.users.${vars.user}.extraGroups = [ "pico" ];

  swapDevices = [
    {
      device = "/var/swapfile";
      size = 8 * 1024;
    }
  ];

  services.udev.extraRules = ''
    # unload ftdi_sio driver for hyper racks
    ACTION=="add", SUBSYSTEM=="usb", DRIVER=="ftdi_sio", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6015", RUN+="${unbind-ftdi-sio} %k"

    # allow non-root users to access tty
    SUBSYSTEM=="usb", ATTR{idVendor}=="0403", ATTR{idProduct}=="6015", GROUP="dialout", MODE="0660", TAG+="uaccess"
  '';

  services.openvpn = {
    servers = {
      work = {
        config = "config /mnt/shared/.secrets/OVPN/work.ovpn";
        autoStart = false;
        up = ''
          dns_route_file=/run/openvpn-work-preserved-dns-routes
          vpn_dns="''${ifconfig_local%.*}.1"

          if [ -n "''${route_net_gateway:-}" ]; then
            : > "$dns_route_file"

            ${pkgs.systemd}/bin/resolvectl dns \
              | ${pkgs.gnugrep}/bin/grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' \
              | while read -r dns_server; do
                if ${pkgs.iproute2}/bin/ip route replace "$dns_server/32" via "$route_net_gateway"; then
                  printf '%s\n' "$dns_server" >> "$dns_route_file"
                fi
              done
          fi

          if [ -n "$vpn_dns" ]; then
            ${pkgs.systemd}/bin/resolvectl dns "$dev" "$vpn_dns"
            ${pkgs.systemd}/bin/resolvectl default-route "$dev" false
            ${pkgs.systemd}/bin/resolvectl domain "$dev" "~internal"
          fi
        '';
        down = ''
          dns_route_file=/run/openvpn-work-preserved-dns-routes

          if [ -r "$dns_route_file" ]; then
            while read -r dns_server; do
              ${pkgs.iproute2}/bin/ip route del "$dns_server/32" 2>/dev/null || true
            done < "$dns_route_file"

            rm -f "$dns_route_file"
          fi

          ${pkgs.systemd}/bin/resolvectl revert "$dev" || true
        '';
      };
    };
  };
}
