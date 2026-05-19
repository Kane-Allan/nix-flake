{ pkgs, ... }:
{
  home.packages = with pkgs; [
    feh
    imv
    mpv
  ];
}
