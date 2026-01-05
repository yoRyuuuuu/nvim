return {
  "saghen/blink.cmp",
  version = "1.*",
  dependencies = { "rafamadriz/friendly-snippets" },
  opts = {
    keymap = { preset = "default" },
    appearance = { nerd_font_variant = "mono" },
    completion = {
      documentation = { auto_show = true },
      list = { selection = { preselect = true, auto_insert = false } },
    },
    sources = { default = { "lsp", "path", "snippets", "buffer" } },
    fuzzy = { implementation = "prefer_rust_with_warning" },
    cmdline = {
      enabled = true,
      completion = {
        menu = { auto_show = true },
        ghost_text = { enabled = true },
      },
      sources = function()
        local type = vim.fn.getcmdtype()
        -- 検索時はbufferから補完
        if type == "/" or type == "?" then
          return { "buffer" }
        end
        -- コマンドモードではcmdlineとpathから補完
        if type == ":" then
          return { "cmdline", "path" }
        end
        return {}
      end,
    },
  },
  opts_extend = { "sources.default" },
}
