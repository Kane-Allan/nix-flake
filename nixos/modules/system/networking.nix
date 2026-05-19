{ vars, ... }:
{
  networking = {
    hostName = vars.host;
    networkmanager = {
      enable = true;
      wifi.powersave = false;
    };
    firewall = {
      enable = true;
    };
  };

  services.resolved.enable = true; # dns caching
}
