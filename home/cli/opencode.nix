{ pkgs, ... }:
let
  opencode = pkgs.callPackage ../../pkgs/opencode-bin { };
in
{
  programs.opencode = {
    enable = true;
    package = opencode;

    tui.attention = {
      enabled = true;
      notifications = true;
      sound = true;
    };
  };
}
