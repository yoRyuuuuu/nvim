return {
  "petertriho/nvim-scrollbar",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "lewis6991/gitsigns.nvim",
  },
  config = function(_, opts)
    require("scrollbar").setup(opts)
    require("scrollbar.handlers.diagnostic").setup()
    require("scrollbar.handlers.gitsigns").setup()
  end,
  opts = {
    handle = {
      highlight = "Visual",
      blend = 0,
    },
    marks = {
      Error = {
        text = { "󰅚" },
        priority = 2,
        highlight = "DiagnosticError",
      },
      Warn = {
        text = { "󰀪" },
        priority = 3,
        highlight = "DiagnosticWarn",
      },
      Info = {
        text = { "" },
        priority = 4,
        highlight = "DiagnosticInfo",
      },
      Hint = {
        text = { "󰌶" },
        priority = 5,
        highlight = "DiagnosticHint",
      },
    },
  },
}
