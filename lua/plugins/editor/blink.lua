local terraform_filetypes = {
  terraform = true,
  ["terraform-vars"] = true,
  hcl = true,
}

local snippet_kind = vim.lsp.protocol.CompletionItemKind.Snippet

return {
  "saghen/blink.cmp",
  version = "1.*",
  dependencies = { "rafamadriz/friendly-snippets" },
  opts = {
    keymap = {
      preset = "default",
      ["<CR>"] = { "accept", "fallback" },
    },
    appearance = { nerd_font_variant = "mono" },
    completion = {
      documentation = { auto_show = true },
      list = { selection = { preselect = true, auto_insert = false } },
    },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
      per_filetype = {
        terraform = { "lsp", "path", "buffer" },
        ["terraform-vars"] = { "lsp", "path", "buffer" },
        hcl = { "lsp", "path", "buffer" },
      },
      providers = {
        lsp = {
          transform_items = function(ctx, items)
            if not snippet_kind then
              return items
            end

            if not terraform_filetypes[ctx.filetype] then
              return items
            end

            return vim.tbl_filter(function(item)
              local kind = item.kind or (item.completion_item and item.completion_item.kind)
              return kind ~= snippet_kind
            end, items)
          end,
        },
      },
    },
    fuzzy = { implementation = "prefer_rust_with_warning" },
    cmdline = {
      enabled = true,
      completion = {
        menu = { auto_show = true },
        ghost_text = { enabled = true },
      },
      sources = function()
        local type = vim.fn.getcmdtype()
        if type == "/" or type == "?" then
          return { "buffer" }
        end
        if type == ":" then
          return { "cmdline", "path" }
        end
        return {}
      end,
    },
  },
  opts_extend = { "sources.default" },
}
