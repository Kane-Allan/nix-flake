{ pkgs, ... }:
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
      efiInstallAsRemovable = true;
    };

    efi = {
      canTouchEfiVariables = false;
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
    subversion
    teamviewer
  ];

  nixpkgs.config.segger-jlink.acceptLicense = true;

  swapDevices = [
    {
      device = "/var/swapfile";
      size = 8 * 1024;
    }
  ];

  services.udev.extraRules = ''
    # unload ftdi_sio driver for hyper racks
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0403", ATTR{idProduct}=="6015", ATTR{manufacturer}=="FTDI", ENV{ID_MODULE}="ftdi_sio"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0403", ATTR{idProduct}=="6015", DRIVER=="ftdi_sio", RUN+="/bin/sh -c 'echo -n $kernel > /sys/bus/usb/drivers/ftdi_sio/unbind'"
    SUBSYSTEM=="usb", ATTR{idVendor}=="0403", ATTR{idProduct}=="6015", GROUP="dialout", MODE="0666"

    # allow non-root users to access tty
    KERNEL=="ttyACM[0-9]*", GROUP="dialout", MODE="0660"
  '';

  services.openvpn = {
    servers = {
      work = {
        config = "/mnt/shared/.secrets/OpenVPN/config/work.ovpn";
        autoStart = false;
      };
    };
  };
}
