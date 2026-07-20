let
  prettier = [ "prettierd" ];
in
{
  programs.nixvim.plugins.conform-nvim = {
    enable = true;
    settings = {
      formatters_by_ft = {
        javascript = prettier;
        javascriptreact = prettier;
        typescript = prettier;
        typescriptreact = prettier;
        json = prettier;
        jsonc = prettier;
        yaml = prettier;
        css = prettier;
        scss = prettier;
        less = prettier;
        html = prettier;
        markdown = [
          "prettierd"
          "markdownlint-cli2"
          "markdown-toc"
        ];
        "markdown.mdx" = [
          "prettierd"
          "markdownlint-cli2"
          "markdown-toc"
        ];
        graphql = prettier;
        handlebars = prettier;
        vue = prettier;
        svelte = prettier;
        php = [ "php_cs_fixer" ];
        c = [ "clang_format" ];
        cpp = [ "clang_format" ];
        cs = [ "csharpier" ];
        fsharp = [ "fantomas" ];
        lua = [ "stylua" ];
        nix = [ "nixfmt" ];
        "_" = [
          "trim_whitespace"
          "trim_newlines"
        ];
      };
      format_on_save = {
        timeout_ms = 3000;
        lsp_format = "fallback";
      };
      formatters = {
        "markdown-toc".condition.__raw = ''
          function(_, context)
            for _, line in ipairs(vim.api.nvim_buf_get_lines(context.buf, 0, -1, false)) do
              if line:find("<!%-%- toc %-%->") then
                return true
              end
            end
            return false
          end
        '';
        "markdownlint-cli2".condition.__raw = ''
          function(_, context)
            for _, diagnostic in ipairs(vim.diagnostic.get(context.buf)) do
              if diagnostic.source == "markdownlint" then
                return true
              end
            end
            return false
          end
        '';
      };
    };
  };
}
