return {
  "petertriho/nvim-scrollbar",
  -- v2 lands on main on 2026-11-16; drop this line after that.
  branch = "refactor/v2",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "lewis6991/gitsigns.nvim",
  },
  opts = {
    providers = {
      diagnostic = true,
      gitsigns = true,
    },
    scrollbar = {
      thumb = {
        highlight = "Visual",
        blend = 0,
      },
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
