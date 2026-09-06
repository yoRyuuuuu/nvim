return {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  opts = {
    check_ts = true,
    -- Wrap the text after the cursor in a pair. Default <M-e>; remapped off Alt.
    fast_wrap = {
      map = "<C-e>",
    },
  },
  config = function(_, opts)
    require("nvim-autopairs").setup(opts)
  end,
}
