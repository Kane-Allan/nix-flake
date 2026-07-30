{
  programs.nixvim.plugins.lint = {
    enable = true;
    lintersByFt = {
      nix = [
        "statix"
        "deadnix"
      ];
      sh = [ "shellcheck" ];
      bash = [ "shellcheck" ];
      markdown = [ "markdownlint-cli2" ];
      "markdown.mdx" = [ "markdownlint-cli2" ];
    };
    autoCmd = {
      event = [
        "BufReadPost"
        "BufWritePost"
        "InsertLeave"
      ];
      callback.__raw = "function() _G.Lint() end";
    };
  };
}
