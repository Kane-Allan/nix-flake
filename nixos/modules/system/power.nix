{ vars, ... }:
{
  services = {
    power-profiles-daemon.enable = true;

    upower = {
      enable = true;
      usePercentageForPolicy = true;
      percentageLow = 20;
      percentageCritical = 10;
      percentageAction = 5;
    };
  };

  home-manager.users.${vars.user}.services.poweralertd = {
    enable = true;
    extraArgs = [ "-S" ];
  };
}
