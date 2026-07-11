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
    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;
}
