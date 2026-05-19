{ inputs, ... }:
{
  imports = [
    inputs.nixvim.homeModules.nixvim
    ./ideavim.nix
    ./nixvim
    ./vscode.nix
  ];
}
