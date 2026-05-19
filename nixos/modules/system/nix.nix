{ inputs, vars, ... }:
{
  nixpkgs = {
    overlays = [
      inputs.nix-vscode-extensions.overlays.default
    ];
    config.allowUnfree = true;
  };

  nix = {
    optimise.automatic = true;
    registry.nixpkgs.flake = inputs.nixpkgs;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "root"
        vars.user
      ];
    };
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';
  };

  programs = {
    nix-ld.enable = true;

    nh = {
      enable = true;
      flake = vars.flake;
      clean = {
        enable = true;
        dates = "daily";
        extraArgs = "--delete-older-than 7d --keep 3";
      };
    };
  };
}
