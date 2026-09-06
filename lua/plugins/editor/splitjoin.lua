-- Toggle a construct between one line and multiple lines, driven by treesitter
-- so it covers Lua / Go / Rust / TS / HCL alike. `gS` splits, `gJ` joins.
-- One keystroke instead of manual `f, a<CR>` loops through the symbol layer.
return {
  "Wansmer/treesj",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  keys = {
    { "gS", function() require("treesj").split() end, desc = "Split construct" },
    { "gJ", function() require("treesj").join() end, desc = "Join construct" },
  },
  opts = {
    use_default_keymaps = false,
    max_join_length = 150,
  },
}
