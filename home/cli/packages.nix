{ pkgs, ... }:
{
  home.packages = with pkgs; [
    bat
    dua
    dust
    jq
    p7zip
    xh
    yq
  ];
}
