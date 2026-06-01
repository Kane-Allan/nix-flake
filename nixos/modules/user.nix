{ pkgs, vars, ... }:
{
  programs.zsh.enable = true;

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
    ];
    shell = pkgs.zsh;
  };
}
