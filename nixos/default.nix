{ inputs, ... }:
let
  baseVars = {
    user = "kane";
    home = "/home/kane";
    flake = "/home/kane/nix-flake";

    terminal = "ghostty";
    browser = "brave";
  };

  system = "x86_64-linux";

  modules = [
    inputs.stylix.nixosModules.stylix
    ./modules/system
    ./modules/user.nix
    ./modules/theme.nix
    ./modules/docker.nix
    ./desktops/hyprland
  ];
in
{
  laptop =
    let
      vars = baseVars // {
        host = "laptop";

        hyprland = {
          scale = "2";
          resolution = "2944x1840@90";
        };
      };
    in
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;

      specialArgs = {
        inherit inputs vars;

        host.hostName = vars.host;
      };

      modules = [
        ./hosts/laptop

        inputs.home-manager.nixosModules.default
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {
            inherit inputs vars;
          };
          home-manager.users.${vars.user} = import ../home;
        }
      ]
      ++ modules;
    };

  work =
    let
      vars = baseVars // {
        host = "work";

        hyprland = {
          scale = "1.2";
          resolution = "";
        };
      };
    in
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;

      specialArgs = {
        inherit inputs vars;

        host.hostName = vars.host;
      };

      modules = [
        ./hosts/work

        inputs.home-manager.nixosModules.default
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {
            inherit inputs vars;
          };
          home-manager.users.${vars.user} = import ../home;
        }
      ]
      ++ modules;
    };
}
