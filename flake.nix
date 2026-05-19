{
  description = "Kane's Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { ... }@inputs:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations = import ./nixos {
        inherit inputs;
      };

      formatter.${system} = inputs.nixpkgs.legacyPackages.${system}.nixfmt-tree;
    };
}
