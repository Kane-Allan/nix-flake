{
  hardware.bluetooth = {
    enable = true;

    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        AutoEnable = true;
        ControllerMode = "dual";
      };
    };
  };

  services.blueman.enable = true;
}
