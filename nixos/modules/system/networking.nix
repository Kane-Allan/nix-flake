{ vars, ... }:
{
  networking = {
    hostName = vars.host;
    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
      wifi.powersave = false;
    };
    firewall = {
      enable = true;
      allowedTCPPorts = [ 3000 ];
    };
  };

  services.resolved = {
    enable = true;
    settings.Resolve.FallbackDNS = [
      "1.1.1.1"
      "8.8.8.8"
    ];
  };
}
