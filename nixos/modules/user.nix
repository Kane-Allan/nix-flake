{ pkgs, vars, ... }:
{
  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    filezilla
  ];

  users.users.${vars.user} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
      "docker"
      "dialout"
      "tty"
      "adbusers"
      "input"
    ];
    shell = pkgs.zsh;
  };
}
