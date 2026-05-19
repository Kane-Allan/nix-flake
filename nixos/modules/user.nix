{ pkgs, vars, ... }:
{
  programs.zsh.enable = true;

  programs.chromium = {
    enable = true;

    defaultSearchProviderEnabled = true;
    defaultSearchProviderSearchURL = "https://searxng.enak-nalla.dev/search?q={searchTerms}";
    defaultSearchProviderSuggestURL = "https://searxng.enak-nalla.dev/autocompleter?q={searchTerms}";
  };

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
