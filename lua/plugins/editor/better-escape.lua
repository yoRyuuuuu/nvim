return {
  "max397574/better-escape.nvim",
  event = "InsertEnter",
  opts = {
    timeout = 100,
    default_mappings = false,
    mappings = {
      i = { j = { ["["] = "<ESC>" } },
      t = {
        j = { ["["] = "<C-\\><C-n>" },
      },
    },
  },
  config = function(_, opts)
    require("better_escape").setup(opts)
  end,
}
