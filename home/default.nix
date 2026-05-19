{ vars, ... }:
{
  imports = [
    ./apps
    ./cli
    ./editors
    ./session.nix
    ./shell
    ./theme.nix
  ];

  home = {
    username = vars.user;
    homeDirectory = vars.home;
    stateVersion = "25.11";
  };

  programs.home-manager.enable = true;
}
