let
  prettier = {
    __unkeyed-1 = "prettierd";
    __unkeyed-2 = "prettier";
    stop_after_first = true;
  };
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
        yaml = prettier;
        css = prettier;
        scss = prettier;
        less = prettier;
        html = prettier;
        markdown = prettier;
        vue = prettier;
        svelte = prettier;
        php = [ "php_cs_fixer" ];
        c = [ "clang_format" ];
        cpp = [ "clang_format" ];
        lua = [ "stylua" ];
        nix = [ "nixfmt" ];
        "_" = [
          "trim_whitespace"
          "trim_newlines"
        ];
      };
      formatters = {
        prettierd.prepend_args.__raw = "function(self, ctx) return _G.KanePrettierArgs(ctx) end";
        prettier.prepend_args.__raw = "function(self, ctx) return _G.KanePrettierArgs(ctx) end";
      };
      format_on_save = {
        timeout_ms = 5000;
        lsp_format = "fallback";
      };
    };
  };
}
