return {
  "max397574/better-escape.nvim",
  event = "InsertEnter",
  opts = {
    mapping = { "jk" },
    timeout = vim.o.timeoutlen,
  },
  config = function(_, opts)
    require("better_escape").setup(opts)
  end,
}
