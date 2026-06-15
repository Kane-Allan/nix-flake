{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.brightnessctl
  ];

  services.udev.packages = [
    pkgs.brightnessctl
  ];
}
