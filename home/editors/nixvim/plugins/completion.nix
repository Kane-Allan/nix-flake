{
  programs.nixvim.plugins = {
    luasnip.enable = true;
    friendly-snippets.enable = true;

    cmp = {
      enable = true;
      autoEnableSources = true;
      settings = {
        snippet.expand = "function(args) require('luasnip').lsp_expand(args.body) end";
        mapping.__raw = ''
          cmp.mapping.preset.insert({
            ["<C-Space>"] = cmp.mapping.complete(),
            ["<C-e>"] = cmp.mapping.abort(),
            ["<C-b>"] = cmp.mapping.scroll_docs(-4),
            ["<C-f>"] = cmp.mapping.scroll_docs(4),
            ["<CR>"] = cmp.mapping.confirm({ select = true }),
            ["<Tab>"] = cmp.mapping(function(fallback)
              local luasnip = require("luasnip")
              if cmp.visible() then
                cmp.select_next_item()
              elseif luasnip.expand_or_locally_jumpable() then
                luasnip.expand_or_jump()
              else
                fallback()
              end
            end, { "i", "s" }),
            ["<S-Tab>"] = cmp.mapping(function(fallback)
              local luasnip = require("luasnip")
              if cmp.visible() then
                cmp.select_prev_item()
              elseif luasnip.locally_jumpable(-1) then
                luasnip.jump(-1)
              else
                fallback()
              end
            end, { "i", "s" }),
          })
        '';
        sources = [
          { name = "nvim_lsp"; }
          { name = "luasnip"; }
          { name = "path"; }
          { name = "buffer"; }
        ];
        window = {
          completion.__raw = "cmp.config.window.bordered()";
          documentation.__raw = "cmp.config.window.bordered()";
        };
      };
      cmdline.":" = {
        mapping.__raw = "cmp.mapping.preset.cmdline()";
        sources.__raw = ''
          cmp.config.sources({
            { name = "path" }
          }, {
            { name = "cmdline" }
          })
        '';
      };
    };
  };
}
