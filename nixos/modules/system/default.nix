{
  imports = [
    ./nix.nix
    ./audio.nix
    ./locale.nix
    ./bluetooth.nix
    ./networking.nix
  ];

  boot = {
    tmp = {
      cleanOnBoot = true;
      useTmpfs = true;
      tmpfsSize = "50%";
    };

    loader.timeout = 5;
  };

  services = {
    udisks2.enable = true;
  };

  system.stateVersion = "25.11";
}
