{ pkgs, vars, ... }:
{
  programs.nixvim.plugins.lsp = {
    enable = true;
    inlayHints = true;
    servers = {
      ts_ls = {
        enable = true;
        package = pkgs.typescript-language-server;
      };
      eslint.enable = true;
      tailwindcss.enable = true;
      html.enable = true;
      cssls.enable = true;
      jsonls.enable = true;
      cmake.enable = true;
      intelephense = {
        enable = true;
        package = pkgs.intelephense;
      };
      phpactor = {
        enable = true;
        package = pkgs.phpactor;
      };
      nixd = {
        enable = true;
        settings = {
          nixpkgs.expr = ''
            (builtins.getFlake "${vars.flake}").inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}
          '';

          formatting.command = [ "nixfmt" ];

          options = {
            nixos.expr = ''
              (builtins.getFlake "${vars.flake}").nixosConfigurations.${vars.host}.options
            '';
            home-manager.expr = ''
              (builtins.getFlake "${vars.flake}").nixosConfigurations.${vars.host}.options.home-manager.users.type.getSubOptions []
            '';
          };
        };
      };

      clangd = {
        enable = true;
        cmd =
          let
            queryDrivers = [
              "**/bin/*-gcc"
              "**/bin/*-g++"
              "**/bin/gcc"
              "**/bin/g++"
              "**/bin/cc"
              "**/bin/c++"
              "**/bin/clang"
              "**/bin/clang++"
            ];
          in
          [
            "clangd"
            "--background-index"
            "--clang-tidy"
            "--completion-style=detailed"
            "--query-driver=${builtins.concatStringsSep "," queryDrivers}"
          ];
      };

      lua_ls = {
        enable = true;
        settings = {
          diagnostics.globals = [ "vim" ];
          workspace.checkThirdParty = false;
          telemetry.enable = false;
        };
      };
    };
  };
}
