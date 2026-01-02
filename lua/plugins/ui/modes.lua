return {
  {
    "mvllow/modes.nvim",
    event = "VeryLazy",
    opts = {
      colors = {
        copy = "#d8a657",
        delete = "#ea6962",
        format = "#7daea3",
        insert = "#a9b665",
        replace = "#d3869b",
        visual = "#d3869b",
      },

      -- Set opacity for cursorline and number background
      line_opacity = 0.3,

      -- Enable cursor highlights
      set_cursor = true,

      -- Enable cursorline initially, and disable cursorline for inactive windows
      -- or ignored filetypes
      set_cursorline = true,

      -- Enable line number highlights to match cursorline
      set_number = true,

      -- Enable sign column highlights to match cursorline
      set_signcolumn = true,
    },
  },
}
