return {
  "stevearc/conform.nvim",
  keys = {
    {
      "<leader>lf",
      function()
        require("conform").format({ lsp_fallback = true })
      end,
      mode = { "n", "v" },
      desc = "Format buffer",
    },
  },
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
    },
  },
}
