return {
  "folke/sidekick.nvim",
  opts = {},
  keys = {
    { "<leader>aa", function() require("sidekick.cli").toggle() end, desc = "Sidekick Toggle CLI" },
    { "<leader>as", function() require("sidekick.cli").select() end, desc = "Sidekick Select CLI" },
  },
}
