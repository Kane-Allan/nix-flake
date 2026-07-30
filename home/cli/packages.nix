{ pkgs, ... }:
{
  home.packages = with pkgs; [
    bat
    dua
    jq
    xh
    yq
    unzip
    usbutils
    lsof
    unrar
    devenv
  ];
}
