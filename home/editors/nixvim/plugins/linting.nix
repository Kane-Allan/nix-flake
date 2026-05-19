{
  programs.nixvim.plugins.lint = {
    enable = true;
    lintersByFt = {
      javascript = [ "eslint_d" ];
      javascriptreact = [ "eslint_d" ];
      typescript = [ "eslint_d" ];
      typescriptreact = [ "eslint_d" ];
      vue = [ "eslint_d" ];
      svelte = [ "eslint_d" ];
      nix = [
        "statix"
        "deadnix"
      ];
      sh = [ "shellcheck" ];
      bash = [ "shellcheck" ];
      markdown = [ "markdownlint" ];
    };
    autoCmd = {
      event = [
        "BufReadPost"
        "BufWritePost"
        "InsertLeave"
      ];
      callback.__raw = "function() _G.KaneLint() end";
    };
  };
}
