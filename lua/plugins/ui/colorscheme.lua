return {
  {
    "sainnhe/gruvbox-material",
    lazy = false,
    priority = 1000,
    init = function()
      vim.o.background = "dark"
      vim.g.gruvbox_material_foreground = "material"
      vim.g.gruvbox_material_enable_bold = 1
      vim.g.gruvbox_material_enable_italic = 1
      vim.g.gruvbox_material_transparent_background = 1
    end,
    config = function()
      -- The Rust treesitter query tags `assert*!` / `panic!` / `try` as
      -- @keyword.exception, which gruvbox-material paints red. Make those
      -- macros read like any other macro instead.
      local function tweak()
        vim.api.nvim_set_hl(0, "@keyword.exception.rust", { link = "@function.macro" })
      end
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "gruvbox-material",
        callback = tweak,
      })

      vim.cmd.colorscheme("gruvbox-material")
      tweak()
    end,
  },
}
