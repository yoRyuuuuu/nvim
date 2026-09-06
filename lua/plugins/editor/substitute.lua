-- Replace / exchange operators that do not clobber named registers.
-- `<leader>s{motion}` stamps the yanked text over the motion; `<leader>sx`
-- exchanges two regions. Avoids typing `"` (symbol layer) for `"0p` dances.
return {
  "gbprod/substitute.nvim",
  opts = {},
  keys = {
    { "<leader>s", function() require("substitute").operator() end, mode = "n", desc = "Substitute (motion)" },
    { "<leader>ss", function() require("substitute").line() end, desc = "Substitute line" },
    { "<leader>S", function() require("substitute").eol() end, desc = "Substitute to EOL" },
    { "<leader>s", function() require("substitute").visual() end, mode = "x", desc = "Substitute" },
    { "<leader>sx", function() require("substitute.exchange").operator() end, mode = "n", desc = "Exchange (motion)" },
    { "<leader>sxx", function() require("substitute.exchange").line() end, desc = "Exchange line" },
    { "<leader>sx", function() require("substitute.exchange").visual() end, mode = "x", desc = "Exchange" },
  },
}
