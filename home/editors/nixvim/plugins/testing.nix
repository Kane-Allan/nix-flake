{
  programs.nixvim.plugins.neotest = {
    enable = true;
    adapters.jest = {
      enable = true;
      settings = {
        jestCommand.__raw = ''
          function(path)
            local package = vim.fs.root(path, "package.json")
            return "pnpm --dir " .. vim.fn.shellescape(package) .. " exec jest"
          end
        '';
        jestConfigFile.__raw = ''
          function(path)
            local package = vim.fs.root(path, "package.json")
            if path:match("/apps/auth/test/.*%.e2e%-spec%.ts$") then
              return package .. "/test/jest-e2e.config.mjs"
            end
            local config = package and (package .. "/jest.config.mjs") or nil
            return config and vim.uv.fs_stat(config) and config or nil
          end
        '';
        cwd.__raw = ''
          function(path)
            return vim.fs.root(path, "package.json") or vim.fn.getcwd()
          end
        '';
        env = {
          NODE_OPTIONS = "--experimental-vm-modules";
        };
      };
    };
    settings = {
      output.open_on_run = true;
      quickfix.open = false;
      status.virtual_text = true;
      summary.animated = true;
    };
  };
}
